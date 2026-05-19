import { useState, useEffect, useRef } from "react";

const sentences = [
  {
    id: 1,
    ko: "내 조카는 거북이를 키워",
    en: "My nephew has a turtle.",
    verb: "HAVE",
    category: "소유/관계",
    hint: "have = 가지고 있다",
    image: "🐢",
    imageBg: "#E6F1FB",
  },
  {
    id: 2,
    ko: "시카고에 친구들이 있어",
    en: "I have friends in Chicago.",
    verb: "HAVE",
    category: "소유/관계",
    hint: "have + 명사 = ~이 있다",
    image: "🏙️",
    imageBg: "#E1F5EE",
  },
  {
    id: 3,
    ko: "내 생각은 달랐어",
    en: "I had a different idea.",
    verb: "HAVE",
    category: "소유/관계",
    hint: "had = 과거에 가지고 있었다",
    image: "💡",
    imageBg: "#FFF8E1",
  },
  {
    id: 4,
    ko: "우리 우애가 돈독해",
    en: "We have a strong bond.",
    verb: "HAVE",
    category: "소유/관계",
    hint: "have a bond = 유대를 가지다",
    image: "🤝",
    imageBg: "#FCE4EC",
  },
  {
    id: 5,
    ko: "현금 있어?",
    en: "Do you have any cash on you?",
    verb: "HAVE",
    category: "소유/관계",
    hint: "on you = 지금 몸에 지니고",
    image: "💵",
    imageBg: "#E8F5E9",
  },
];

const VerbImage = ({ emoji, bg, size = 88 }) => (
  <div
    style={{
      width: size,
      height: size,
      borderRadius: "50%",
      background: bg,
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      fontSize: size * 0.45,
      flexShrink: 0,
    }}
  >
    {emoji}
  </div>
);

const MicButton = ({ listening, onClick }) => (
  <button
    onClick={onClick}
    style={{
      width: 64,
      height: 64,
      borderRadius: "50%",
      border: "none",
      background: listening ? "#1a1a1a" : "#f2f2f2",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      cursor: "pointer",
      transition: "all 0.2s",
      boxShadow: listening ? "0 0 0 8px rgba(0,0,0,0.08)" : "none",
      flexShrink: 0,
    }}
  >
    <svg width="26" height="26" viewBox="0 0 24 24" fill="none">
      <rect
        x="9" y="2" width="6" height="12" rx="3"
        fill={listening ? "white" : "#1a1a1a"}
      />
      <path
        d="M5 10c0 3.866 3.134 7 7 7s7-3.134 7-7"
        stroke={listening ? "white" : "#1a1a1a"}
        strokeWidth="2" strokeLinecap="round"
      />
      <line
        x1="12" y1="17" x2="12" y2="21"
        stroke={listening ? "white" : "#1a1a1a"}
        strokeWidth="2" strokeLinecap="round"
      />
    </svg>
  </button>
);

const WaveBar = ({ delay, listening }) => (
  <div
    style={{
      width: 3,
      height: listening ? 24 : 6,
      borderRadius: 4,
      background: "#1a1a1a",
      opacity: listening ? 0.7 : 0.25,
      transition: `height 0.3s ease ${delay}s`,
      animation: listening ? `wave 0.8s ${delay}s ease-in-out infinite alternate` : "none",
    }}
  />
);

export default function App() {
  const [screen, setScreen] = useState("mission"); // mission | study | answer | expand | done
  const [current, setCurrent] = useState(0);
  const [showAnswer, setShowAnswer] = useState(false);
  const [listening, setListening] = useState(false);
  const [completed, setCompleted] = useState([]);
  const [showHint, setShowHint] = useState(false);
  const [expandOpen, setExpandOpen] = useState(false);
  const timerRef = useRef(null);

  const sent = sentences[current];
  const progress = completed.length / sentences.length;

  const startListen = () => {
    setListening(true);
    timerRef.current = setTimeout(() => {
      setListening(false);
      setShowAnswer(true);
    }, 2200);
  };

  const nextSentence = () => {
    const newCompleted = [...completed, current];
    setCompleted(newCompleted);
    setShowAnswer(false);
    setShowHint(false);
    setListening(false);
    if (current + 1 >= sentences.length) {
      setScreen("done");
    } else {
      setCurrent(current + 1);
    }
  };

  useEffect(() => () => clearTimeout(timerRef.current), []);

  // ── MISSION SCREEN ──────────────────────────────────────
  if (screen === "mission") {
    return (
      <Phone>
        <style>{`
          @keyframes wave { from { height: 8px; } to { height: 28px; } }
          @keyframes pop { 0%{transform:scale(0.8);opacity:0} 100%{transform:scale(1);opacity:1} }
          @keyframes slideUp { from{transform:translateY(20px);opacity:0} to{transform:translateY(0);opacity:1} }
        `}</style>

        {/* Header */}
        <div style={{ padding: "20px 20px 0", display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{
            width: 36, height: 36, borderRadius: "50%",
            background: "#1a1a1a", display: "flex", alignItems: "center",
            justifyContent: "center", fontSize: 18,
          }}>🧠</div>
          <div>
            <div style={{ fontSize: 16, fontWeight: 600, color: "#1a1a1a" }}>English Brain</div>
            <div style={{ fontSize: 11, color: "#999" }}>영어뇌 훈련 앱</div>
          </div>
        </div>

        <div style={{ padding: "24px 20px 0" }}>
          {/* Day badge */}
          <div style={{ fontSize: 11, fontWeight: 600, color: "#999", letterSpacing: "0.08em", marginBottom: 8 }}>
            DAY 1 · HAVE 소유/관계
          </div>

          {/* Mission card */}
          <div style={{
            background: "#1a1a1a", borderRadius: 20, padding: "22px 20px",
            marginBottom: 16, animation: "slideUp 0.4s ease",
          }}>
            <div style={{ fontSize: 13, color: "#888", marginBottom: 6 }}>오늘의 미션</div>
            <div style={{ fontSize: 26, fontWeight: 700, color: "white", marginBottom: 4 }}>
              5문장 완성하기
            </div>
            <div style={{ fontSize: 13, color: "#666", marginBottom: 18 }}>
              듣고 → 연상하고 → 바로 말하기
            </div>

            {/* Progress dots */}
            <div style={{ display: "flex", gap: 8, marginBottom: 20 }}>
              {sentences.map((_, i) => (
                <div key={i} style={{
                  flex: 1, height: 4, borderRadius: 2,
                  background: completed.includes(i) ? "#4ade80" : "rgba(255,255,255,0.15)",
                  transition: "background 0.3s",
                }} />
              ))}
            </div>

            <button
              onClick={() => setScreen("study")}
              style={{
                width: "100%", padding: "14px 0", borderRadius: 14,
                border: "none", background: "white", color: "#1a1a1a",
                fontSize: 15, fontWeight: 600, cursor: "pointer",
              }}
            >
              시작하기 →
            </button>
          </div>

          {/* Expand option */}
          <div style={{
            border: "1.5px solid #f0f0f0", borderRadius: 16, padding: "14px 16px",
            marginBottom: 12,
          }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: "#1a1a1a", marginBottom: 10 }}>
              ✦ 추가 확장 학습
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
              {[
                { icon: "⏳", label: "시제 변형" },
                { icon: "🔄", label: "긍정/부정" },
                { icon: "❓", label: "질문/맞장구" },
                { icon: "📍", label: "장소·시간" },
              ].map((item) => (
                <div key={item.label} style={{
                  background: "#fafafa", borderRadius: 10, padding: "10px 12px",
                  display: "flex", alignItems: "center", gap: 8,
                  fontSize: 12, color: "#555",
                }}>
                  <span style={{ fontSize: 16 }}>{item.icon}</span>
                  {item.label}
                </div>
              ))}
            </div>
          </div>

          {/* Stats */}
          <div style={{ display: "flex", gap: 8 }}>
            {[
              { label: "연속", value: "3일" },
              { label: "완료", value: "12문장" },
              { label: "정확도", value: "86%" },
            ].map((s) => (
              <div key={s.label} style={{
                flex: 1, background: "#fafafa", borderRadius: 12,
                padding: "12px 10px", textAlign: "center",
              }}>
                <div style={{ fontSize: 17, fontWeight: 700, color: "#1a1a1a" }}>{s.value}</div>
                <div style={{ fontSize: 10, color: "#aaa", marginTop: 2 }}>{s.label}</div>
              </div>
            ))}
          </div>
        </div>

        {/* Bottom nav */}
        <BottomNav />
      </Phone>
    );
  }

  // ── STUDY SCREEN ──────────────────────────────────────
  if (screen === "study") {
    return (
      <Phone>
        <style>{`
          @keyframes wave { from { height: 8px; } to { height: 28px; } }
          @keyframes pop { 0%{transform:scale(0.85);opacity:0} 100%{transform:scale(1);opacity:1} }
          @keyframes fadeIn { from{opacity:0;transform:translateY(10px)} to{opacity:1;transform:translateY(0)} }
        `}</style>

        {/* Top bar */}
        <div style={{
          padding: "18px 20px 12px",
          display: "flex", alignItems: "center", justifyContent: "space-between",
        }}>
          <button onClick={() => setScreen("mission")} style={ghostBtn}>
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
              <path d="M19 12H5M12 5l-7 7 7 7" stroke="#1a1a1a" strokeWidth="2" strokeLinecap="round"/>
            </svg>
          </button>
          <div style={{ fontSize: 13, color: "#aaa" }}>
            {current + 1} / {sentences.length}
          </div>
          <div style={{ width: 32 }} />
        </div>

        {/* Progress bar */}
        <div style={{ padding: "0 20px 20px" }}>
          <div style={{ height: 3, background: "#f0f0f0", borderRadius: 2 }}>
            <div style={{
              height: "100%", borderRadius: 2, background: "#1a1a1a",
              width: `${((current) / sentences.length) * 100}%`,
              transition: "width 0.4s",
            }} />
          </div>
        </div>

        {/* Verb tag */}
        <div style={{ padding: "0 20px 16px" }}>
          <span style={{
            fontSize: 11, fontWeight: 700, letterSpacing: "0.1em",
            background: "#1a1a1a", color: "white",
            padding: "4px 10px", borderRadius: 20,
          }}>
            {sent.verb} · {sent.category}
          </span>
        </div>

        {/* Image card */}
        <div style={{ padding: "0 20px 20px" }}>
          <div style={{
            background: sent.imageBg, borderRadius: 24,
            padding: "32px 20px", textAlign: "center",
            animation: "pop 0.35s ease",
          }}>
            <div style={{ fontSize: 80, lineHeight: 1, marginBottom: 16 }}>{sent.image}</div>
            <div style={{
              fontSize: 18, fontWeight: 600, color: "#1a1a1a",
              lineHeight: 1.5,
            }}>
              {sent.ko}
            </div>
            {showHint && (
              <div style={{
                marginTop: 12, fontSize: 13, color: "#666",
                background: "rgba(255,255,255,0.7)", borderRadius: 10,
                padding: "6px 14px", display: "inline-block",
                animation: "fadeIn 0.2s ease",
              }}>
                💡 {sent.hint}
              </div>
            )}
          </div>
        </div>

        {/* Answer area */}
        {showAnswer ? (
          <div style={{ padding: "0 20px", animation: "fadeIn 0.3s ease" }}>
            <div style={{
              background: "#f8f8f8", borderRadius: 18, padding: "18px 20px",
              marginBottom: 14,
            }}>
              <div style={{ fontSize: 12, color: "#aaa", marginBottom: 6 }}>모범 답안</div>
              <div style={{ fontSize: 17, fontWeight: 600, color: "#1a1a1a", marginBottom: 10 }}>
                {sent.en}
              </div>
              {/* Playback button */}
              <button style={{
                display: "flex", alignItems: "center", gap: 8,
                background: "white", border: "1px solid #e8e8e8",
                borderRadius: 10, padding: "8px 14px",
                fontSize: 13, color: "#555", cursor: "pointer",
              }}>
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                  <polygon points="5,3 19,12 5,21" fill="#1a1a1a"/>
                </svg>
                원어민 발음 듣기
              </button>
            </div>
            <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
              <button
                onClick={() => { setShowAnswer(false); setShowHint(false); }}
                style={{
                  flex: 1, padding: "13px 0", borderRadius: 14,
                  border: "1.5px solid #e8e8e8", background: "white",
                  fontSize: 14, fontWeight: 500, color: "#555", cursor: "pointer",
                }}
              >
                다시 말하기
              </button>
              <button
                onClick={nextSentence}
                style={{
                  flex: 2, padding: "13px 0", borderRadius: 14,
                  border: "none", background: "#1a1a1a",
                  fontSize: 14, fontWeight: 600, color: "white", cursor: "pointer",
                }}
              >
                다음 문장 →
              </button>
            </div>
          </div>
        ) : (
          <div style={{ padding: "0 20px" }}>
            {/* Listening state */}
            <div style={{
              display: "flex", alignItems: "center", justifyContent: "center",
              gap: 14, marginBottom: 20, minHeight: 44,
            }}>
              {listening ? (
                <>
                  {[0, 0.1, 0.2, 0.15, 0.05, 0.12, 0.08].map((d, i) => (
                    <WaveBar key={i} delay={d} listening={listening} />
                  ))}
                  <span style={{ fontSize: 13, color: "#888", marginLeft: 4 }}>듣는 중...</span>
                </>
              ) : (
                <span style={{ fontSize: 13, color: "#bbb" }}>
                  영어로 말해보세요
                </span>
              )}
            </div>

            {/* Controls */}
            <div style={{
              display: "flex", alignItems: "center", justifyContent: "center",
              gap: 24, marginBottom: 14,
            }}>
              <button
                onClick={() => setShowHint(!showHint)}
                style={{
                  ...ghostBtn,
                  fontSize: 12, color: "#aaa", display: "flex",
                  flexDirection: "column", alignItems: "center", gap: 4,
                }}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <circle cx="12" cy="12" r="10" stroke="#ccc" strokeWidth="1.5"/>
                  <path d="M12 7v1m0 4v5" stroke="#ccc" strokeWidth="2" strokeLinecap="round"/>
                </svg>
                힌트
              </button>

              <MicButton listening={listening} onClick={startListen} />

              <button
                onClick={() => setShowAnswer(true)}
                style={{
                  ...ghostBtn,
                  fontSize: 12, color: "#aaa", display: "flex",
                  flexDirection: "column", alignItems: "center", gap: 4,
                }}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" stroke="#ccc" strokeWidth="1.5"/>
                  <circle cx="12" cy="12" r="3" stroke="#ccc" strokeWidth="1.5"/>
                </svg>
                답 보기
              </button>
            </div>

            <div style={{ textAlign: "center", fontSize: 12, color: "#ddd" }}>
              마이크를 누르고 영어로 말해보세요
            </div>
          </div>
        )}

        <BottomNav active="study" />
      </Phone>
    );
  }

  // ── DONE SCREEN ──────────────────────────────────────
  if (screen === "done") {
    return (
      <Phone>
        <style>{`
          @keyframes pop { 0%{transform:scale(0.7);opacity:0} 80%{transform:scale(1.05)} 100%{transform:scale(1);opacity:1} }
          @keyframes slideUp { from{transform:translateY(20px);opacity:0} to{transform:translateY(0);opacity:1} }
        `}</style>
        <div style={{
          flex: 1, display: "flex", flexDirection: "column",
          alignItems: "center", justifyContent: "center", padding: "0 24px",
        }}>
          <div style={{ fontSize: 72, marginBottom: 16, animation: "pop 0.5s ease" }}>🎉</div>
          <div style={{ fontSize: 24, fontWeight: 700, color: "#1a1a1a", marginBottom: 8, textAlign: "center" }}>
            오늘 미션 완료!
          </div>
          <div style={{ fontSize: 14, color: "#999", marginBottom: 32, textAlign: "center" }}>
            5문장 모두 완성했어요 · Day 1 HAVE
          </div>

          {/* Stats */}
          <div style={{
            background: "#1a1a1a", borderRadius: 20, padding: "20px",
            width: "100%", marginBottom: 16, animation: "slideUp 0.4s 0.2s both",
          }}>
            <div style={{ display: "flex", justifyContent: "space-around" }}>
              {[
                { label: "완료 문장", value: "5" },
                { label: "정확도", value: "80%" },
                { label: "연속 학습", value: "3일" },
              ].map((s) => (
                <div key={s.label} style={{ textAlign: "center" }}>
                  <div style={{ fontSize: 24, fontWeight: 700, color: "white" }}>{s.value}</div>
                  <div style={{ fontSize: 11, color: "#666", marginTop: 4 }}>{s.label}</div>
                </div>
              ))}
            </div>
          </div>

          {/* Expand options */}
          <div style={{
            width: "100%", marginBottom: 16, animation: "slideUp 0.4s 0.3s both",
          }}>
            <div style={{ fontSize: 13, fontWeight: 600, color: "#1a1a1a", marginBottom: 10 }}>
              더 공부할까요?
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8 }}>
              {[
                { icon: "⏳", label: "시제 변형", sub: "현재→과거→미래" },
                { icon: "🔄", label: "긍정/부정", sub: "don't / never" },
                { icon: "❓", label: "질문/맞장구", sub: "Really? / Oh yeah?" },
                { icon: "📍", label: "장소·시간", sub: "블록 붙이기" },
              ].map((item) => (
                <button key={item.label} style={{
                  background: "#fafafa", border: "1.5px solid #f0f0f0",
                  borderRadius: 14, padding: "14px 12px", textAlign: "left",
                  cursor: "pointer",
                }}>
                  <div style={{ fontSize: 22, marginBottom: 6 }}>{item.icon}</div>
                  <div style={{ fontSize: 13, fontWeight: 600, color: "#1a1a1a" }}>{item.label}</div>
                  <div style={{ fontSize: 11, color: "#aaa", marginTop: 2 }}>{item.sub}</div>
                </button>
              ))}
            </div>
          </div>

          <button
            onClick={() => { setScreen("mission"); setCurrent(0); setCompleted([]); }}
            style={{
              width: "100%", padding: "15px 0", borderRadius: 16,
              border: "none", background: "#1a1a1a",
              fontSize: 15, fontWeight: 600, color: "white", cursor: "pointer",
              animation: "slideUp 0.4s 0.4s both",
            }}
          >
            홈으로 돌아가기
          </button>
        </div>
      </Phone>
    );
  }
}

// ── Shared Components ──────────────────────────────────
const ghostBtn = {
  background: "transparent", border: "none",
  cursor: "pointer", padding: 6,
};

function Phone({ children }) {
  return (
    <div style={{
      minHeight: "100vh", background: "#f5f5f5",
      display: "flex", alignItems: "center", justifyContent: "center",
      fontFamily: "-apple-system, 'SF Pro Display', sans-serif",
    }}>
      <div style={{
        width: 375, minHeight: 780, background: "white",
        borderRadius: 44, boxShadow: "0 30px 80px rgba(0,0,0,0.18)",
        display: "flex", flexDirection: "column",
        overflow: "hidden", position: "relative",
      }}>
        {/* Status bar */}
        <div style={{
          display: "flex", justifyContent: "space-between",
          alignItems: "center", padding: "14px 28px 0",
          fontSize: 13, fontWeight: 600, color: "#1a1a1a",
        }}>
          <span>9:41</span>
          <div style={{
            width: 120, height: 30, background: "#1a1a1a",
            borderRadius: 20, display: "flex", alignItems: "center",
            justifyContent: "center",
          }}>
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: "#555" }} />
          </div>
          <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
            <svg width="16" height="12" viewBox="0 0 16 12">
              <rect x="0" y="6" width="3" height="6" rx="1" fill="#1a1a1a"/>
              <rect x="4.5" y="4" width="3" height="8" rx="1" fill="#1a1a1a"/>
              <rect x="9" y="2" width="3" height="10" rx="1" fill="#1a1a1a"/>
              <rect x="13.5" y="0" width="2.5" height="12" rx="1" fill="#1a1a1a"/>
            </svg>
            <svg width="16" height="12" viewBox="0 0 24 12">
              <rect x="0" y="1" width="20" height="10" rx="3" stroke="#1a1a1a" strokeWidth="1.5" fill="none"/>
              <rect x="2" y="3" width="14" height="6" rx="1.5" fill="#1a1a1a"/>
              <rect x="21" y="4" width="3" height="4" rx="1" fill="#1a1a1a"/>
            </svg>
          </div>
        </div>
        <div style={{ flex: 1, display: "flex", flexDirection: "column" }}>
          {children}
        </div>
      </div>
    </div>
  );
}

function BottomNav({ active }) {
  const items = [
    { icon: "🏠", label: "홈", key: "mission" },
    { icon: "📚", label: "학습", key: "study" },
    { icon: "🔁", label: "복습", key: "review" },
    { icon: "📊", label: "기록", key: "stats" },
  ];
  return (
    <div style={{
      borderTop: "1px solid #f0f0f0",
      display: "flex", padding: "10px 0 24px",
      background: "white",
    }}>
      {items.map((item) => (
        <div key={item.key} style={{
          flex: 1, textAlign: "center", cursor: "pointer",
        }}>
          <div style={{ fontSize: 22 }}>{item.icon}</div>
          <div style={{
            fontSize: 10, marginTop: 3,
            color: active === item.key ? "#1a1a1a" : "#ccc",
            fontWeight: active === item.key ? 600 : 400,
          }}>
            {item.label}
          </div>
        </div>
      ))}
    </div>
  );
}
