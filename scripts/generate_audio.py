#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI 음성 자동 생성 스크립트
ElevenLabs API → 180문장 mp3 자동 생성 → Supabase Storage 업로드 → DB audio_url 업데이트

사용법:
  pip install requests supabase
  python3 generate_audio.py

필요한 환경변수 (.env 파일 또는 직접 입력):
  ELEVENLABS_KEY  - ElevenLabs API 키 (https://elevenlabs.io 에서 발급)
  SUPABASE_URL    - https://jslotdbzorvyzwvdilvj.supabase.co
  SUPABASE_KEY    - anon key
"""

import os, time, json, requests
from pathlib import Path

# ── 설정 ──────────────────────────────────────────────────
ELEVENLABS_KEY = os.getenv('ELEVENLABS_KEY', 'YOUR_ELEVENLABS_KEY')
SUPABASE_URL   = os.getenv('SUPABASE_URL',   'https://jslotdbzorvyzwvdilvj.supabase.co')
SUPABASE_KEY   = os.getenv('SUPABASE_KEY',   'YOUR_ANON_KEY')

# ElevenLabs 음성 ID (미국 영어 원어민 남성/여성)
# https://elevenlabs.io/docs/voices 에서 원하는 voice_id 선택
VOICE_ID_NORMAL = "EXAVITQu4vr4xnSDxMaL"   # Bella (여성, 자연스러운)
VOICE_ID_SLOW   = "21m00Tcm4TlvDq8ikWAM"   # Rachel (여성, 차분함)

OUTPUT_DIR = Path("audio_files")
OUTPUT_DIR.mkdir(exist_ok=True)

# ── ElevenLabs TTS ──────────────────────────────────────
def tts(text: str, voice_id: str, speed: float = 1.0) -> bytes:
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {"xi-api-key": ELEVENLABS_KEY, "Content-Type": "application/json"}
    body = {
        "text": text,
        "model_id": "eleven_monolingual_v1",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
    }
    r = requests.post(url, headers=headers, json=body, timeout=30)
    r.raise_for_status()
    return r.content

# ── Supabase 접근 ──────────────────────────────────────
def sb_get(path: str):
    r = requests.get(f"{SUPABASE_URL}/rest/v1/{path}",
        headers={"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}"})
    r.raise_for_status()
    return r.json()

def sb_upload(bucket: str, file_path: str, data: bytes, mime: str = "audio/mpeg"):
    url = f"{SUPABASE_URL}/storage/v1/object/{bucket}/{file_path}"
    r = requests.post(url, data=data,
        headers={"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}",
                 "Content-Type": mime, "x-upsert": "true"})
    r.raise_for_status()
    return f"{SUPABASE_URL}/storage/v1/object/public/{bucket}/{file_path}"

def sb_update(table: str, id_: int, data: dict):
    r = requests.patch(f"{SUPABASE_URL}/rest/v1/{table}?id=eq.{id_}",
        json=data,
        headers={"apikey": SUPABASE_KEY, "Authorization": f"Bearer {SUPABASE_KEY}",
                 "Content-Type": "application/json", "Prefer": "return=minimal"})
    r.raise_for_status()

# ── 메인 ──────────────────────────────────────────────
def main():
    print("📥 예문 목록 가져오는 중...")
    sentences = sb_get("sentences?select=id,en&is_active=eq.true&limit=200")
    print(f"총 {len(sentences)}개 예문\n")

    for i, sent in enumerate(sentences, 1):
        sid = sent['id']
        text = sent['en']
        print(f"[{i}/{len(sentences)}] {text[:50]}")

        # 로컬 캐시 확인
        normal_path = OUTPUT_DIR / f"s{sid}_natural.mp3"
        slow_path   = OUTPUT_DIR / f"s{sid}_slow.mp3"

        try:
            # 보통 속도
            if not normal_path.exists():
                audio = tts(text, VOICE_ID_NORMAL, speed=1.0)
                normal_path.write_bytes(audio)
                print(f"  ✅ natural 생성")
            else:
                audio = normal_path.read_bytes()
                print(f"  ♻️  natural 캐시 사용")

            # 느린 속도
            if not slow_path.exists():
                slow_text = text  # ElevenLabs는 별도 속도 파라미터 없음
                # 대신 안정성 높인 목소리로 자연스럽게 천천히
                audio_slow = tts(slow_text, VOICE_ID_SLOW, speed=0.8)
                slow_path.write_bytes(audio_slow)
                print(f"  ✅ slow 생성")
            else:
                audio_slow = slow_path.read_bytes()
                print(f"  ♻️  slow 캐시 사용")

            # Supabase Storage 업로드
            url_normal = sb_upload("audio", f"s{sid}_natural.mp3", audio)
            url_slow   = sb_upload("audio", f"s{sid}_slow.mp3", audio_slow)

            # DB 업데이트
            sb_update("sentences", sid, {
                "audio_url": url_normal,
                "audio_slow_url": url_slow,
            })
            print(f"  ✅ DB 업데이트 완료")

            time.sleep(0.5)  # API 속도 제한 방지

        except Exception as e:
            print(f"  ❌ 오류: {e}")
            continue

    print(f"\n🎉 완료! {len(sentences)}개 음성 파일 생성 + DB 연결")
    print(f"📁 로컬 파일: {OUTPUT_DIR}/")

if __name__ == "__main__":
    if ELEVENLABS_KEY == 'YOUR_ELEVENLABS_KEY':
        print("⚠️  ELEVENLABS_KEY를 설정해주세요")
        print("   export ELEVENLABS_KEY=your_key_here")
        print("   ElevenLabs 가입 → https://elevenlabs.io (무료 10,000자/월)")
    else:
        main()
