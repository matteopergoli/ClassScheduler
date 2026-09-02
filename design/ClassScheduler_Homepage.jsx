import { useState, useEffect } from "react";

const schools = [
  {
    id: 1,
    name: "Istituto Manzoni",
    classes: 6,
    lastGenerated: "2 Mar 2026",
    qualityScore: 94,
    bestScore: 97,
    status: "perfect",
    teachers: 8,
    slotsUsed: 38,
    slotsTotal: 40,
  },
  {
    id: 2,
    name: "Liceo Scientifico Fermi",
    classes: 10,
    lastGenerated: "28 Feb 2026",
    qualityScore: 78,
    bestScore: 82,
    status: "soft",
    teachers: 12,
    slotsUsed: 76,
    slotsTotal: 80,
  },
  {
    id: 3,
    name: "Scuola Media Verdi",
    classes: 4,
    lastGenerated: "Never",
    qualityScore: null,
    bestScore: null,
    status: "draft",
    teachers: 5,
    slotsUsed: 22,
    slotsTotal: 32,
  },
];

const palette = [
  { from: "#6C63FF", to: "#A78BFA" },
  { from: "#F472B6", to: "#FB7185" },
  { from: "#34D399", to: "#2DD4BF" },
  { from: "#FBBF24", to: "#F97316" },
  { from: "#60A5FA", to: "#818CF8" },
];

const statusConfig = {
  perfect: { label: "Perfect", color: "#10b981", bg: "rgba(16,185,129,0.12)" },
  soft: { label: "Soft violations", color: "#f59e0b", bg: "rgba(245,158,11,0.12)" },
  draft: { label: "Not generated", color: "#94a3b8", bg: "rgba(148,163,184,0.12)" },
};

function QualityRing({ score, size = 52 }) {
  const r = (size - 8) / 2;
  const circ = 2 * Math.PI * r;
  const filled = score != null ? (score / 100) * circ : 0;
  const color = score >= 85 ? "#10b981" : score >= 60 ? "#f59e0b" : "#ef4444";
  return (
    <svg width={size} height={size} style={{ transform: "rotate(-90deg)" }}>
      <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth={6} />
      {score != null && (
        <circle
          cx={size / 2} cy={size / 2} r={r}
          fill="none" stroke={color} strokeWidth={6}
          strokeDasharray={`${filled} ${circ}`}
          strokeLinecap="round"
          style={{ transition: "stroke-dasharray 1s cubic-bezier(.4,0,.2,1)" }}
        />
      )}
      <text
        x={size / 2} y={size / 2 + 5}
        textAnchor="middle"
        style={{ transform: "rotate(90deg)", transformOrigin: `${size / 2}px ${size / 2}px`, fill: score != null ? color : "#64748b", fontSize: score != null ? 13 : 10, fontWeight: 700, fontFamily: "DM Sans, sans-serif" }}
      >
        {score != null ? score : "—"}
      </text>
    </svg>
  );
}

function SchoolCard({ school, index, onEdit }) {
  const [hovered, setHovered] = useState(false);
  const pal = palette[index % palette.length];
  const sc = statusConfig[school.status];
  const pct = Math.round((school.slotsUsed / school.slotsTotal) * 100);
  const isValid = !!(school.classes > 0 && school.teachers > 0 && school.slotsTotal > 0 && school.slotsTotal >= school.slotsUsed);

  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        background: hovered
          ? "rgba(255,255,255,0.06)"
          : "rgba(255,255,255,0.03)",
        border: `1px solid ${hovered ? "rgba(255,255,255,0.18)" : "rgba(255,255,255,0.08)"}`,
        borderRadius: 20,
        padding: "24px 24px 20px",
        cursor: "pointer",
        transition: "all 0.25s cubic-bezier(.4,0,.2,1)",
        transform: hovered ? "translateY(-3px)" : "none",
        boxShadow: hovered
          ? `0 20px 60px rgba(0,0,0,0.4), 0 0 0 1px rgba(255,255,255,0.06)`
          : "0 4px 20px rgba(0,0,0,0.2)",
        position: "relative",
        overflow: "hidden",
      }}
    >
      {/* colour accent bar */}
      <div style={{
        position: "absolute", top: 0, left: 0, right: 0, height: 3,
        background: `linear-gradient(90deg, ${pal.from}, ${pal.to})`,
        borderRadius: "20px 20px 0 0",
      }} />

      {/* top row */}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 16 }}>
        <div>
          <div style={{
            display: "inline-flex", alignItems: "center", gap: 6,
            background: sc.bg, borderRadius: 20, padding: "3px 10px",
            marginBottom: 8,
          }}>
            <div style={{ width: 6, height: 6, borderRadius: "50%", background: sc.color }} />
            <span style={{ color: sc.color, fontSize: 11, fontWeight: 600, letterSpacing: "0.04em", fontFamily: "DM Sans, sans-serif" }}>{sc.label}</span>
          </div>
          <div style={{ color: "#f1f5f9", fontSize: 18, fontWeight: 700, fontFamily: "Playfair Display, serif", lineHeight: 1.2 }}>
            {school.name}
          </div>
          {school.bestScore != null && (
            <div style={{ color: "#94a3b8", fontSize: 11, marginTop: 6, fontWeight: 600 }}>Best: {school.bestScore}</div>
          )}
        </div>
        <QualityRing score={school.qualityScore} />
      </div>

      {/* stats row */}
      <div style={{ display: "flex", gap: 16, marginBottom: 18 }}>
        {[
          { label: "Classes", value: school.classes },
          { label: "Teachers", value: school.teachers },
          { label: "Last run", value: school.lastGenerated },
        ].map(stat => (
          <div key={stat.label}>
            <div style={{ color: "#94a3b8", fontSize: 10, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: "DM Sans, sans-serif", marginBottom: 2 }}>{stat.label}</div>
            <div style={{ color: "#e2e8f0", fontSize: 13, fontWeight: 600, fontFamily: "DM Sans, sans-serif" }}>{stat.value}</div>
          </div>
        ))}
      </div>

      {/* feasibility bar */}
      <div>
        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 5 }}>
          <span style={{ color: "#94a3b8", fontSize: 10, fontWeight: 600, textTransform: "uppercase", letterSpacing: "0.08em", fontFamily: "DM Sans, sans-serif" }}>Lesson slots assigned</span>
          <span style={{ color: "#cbd5e1", fontSize: 11, fontWeight: 700, fontFamily: "DM Sans, sans-serif" }}>{school.slotsUsed}/{school.slotsTotal}h</span>
        </div>
        <div style={{ background: "rgba(255,255,255,0.06)", borderRadius: 6, height: 6, overflow: "hidden" }}>
          <div style={{
            height: "100%", borderRadius: 6,
            background: `linear-gradient(90deg, ${pal.from}, ${pal.to})`,
            width: `${pct}%`,
            transition: "width 1s cubic-bezier(.4,0,.2,1)",
            boxShadow: `0 0 8px ${pal.from}80`,
          }} />
        </div>
      </div>

      {/* action buttons */}
      <div style={{ display: "flex", gap: 8, marginTop: 16 }}>
        <button
          disabled={!isValid}
          onClick={() => isValid && console.log("Generate for", school.id)}
          style={{
            flex: 1,
            background: isValid ? `linear-gradient(135deg, ${pal.from}, ${pal.to})` : "linear-gradient(135deg, rgba(255,255,255,0.03), rgba(255,255,255,0.03))",
            border: "none", borderRadius: 10, padding: "8px 0", color: "#fff",
            fontSize: 12, fontWeight: 700, fontFamily: "DM Sans, sans-serif",
            cursor: isValid ? "pointer" : "not-allowed", letterSpacing: "0.02em",
            boxShadow: isValid ? `0 4px 16px ${pal.from}50` : "none",
            opacity: isValid ? 1 : 0.5,
          }}
        >
          {school.status === "draft" ? "⚡ Generate" : "⚡ Re-generate"}
        </button>
        <button
          onClick={() => onEdit && onEdit(school)}
          style={{
            background: "rgba(255,255,255,0.06)", border: "1px solid rgba(255,255,255,0.1)",
            borderRadius: 10, padding: "8px 14px", color: "#94a3b8",
            fontSize: 12, fontWeight: 600, fontFamily: "DM Sans, sans-serif",
            cursor: "pointer",
          }}
        >
          ✏️ Edit
        </button>
      </div>
    </div>
  );
}

function NavItem({ icon, label, active }) {
  return (
    <div style={{
      display: "flex", flexDirection: "column", alignItems: "center", gap: 4,
      padding: "8px 16px", cursor: "pointer",
      opacity: active ? 1 : 0.45,
      transition: "opacity 0.2s",
    }}>
      <div style={{ fontSize: 20 }}>{icon}</div>
      <div style={{
        fontSize: 10, fontWeight: 600, fontFamily: "DM Sans, sans-serif",
        color: active ? "#a78bfa" : "#94a3b8", letterSpacing: "0.04em",
        textTransform: "uppercase",
      }}>{label}</div>
      {active && <div style={{ width: 4, height: 4, borderRadius: "50%", background: "#a78bfa" }} />}
    </div>
  );
}

export default function App() {
  const [mounted, setMounted] = useState(false);
  const [activeNav, setActiveNav] = useState("Schools");
  const [showTrial, setShowTrial] = useState(true);
  const [selectedSchool, setSelectedSchool] = useState(null);

  useEffect(() => {
    const t = setTimeout(() => setMounted(true), 80);
    return () => clearTimeout(t);
  }, []);

  const navItems = [
    { icon: "🏫", label: "Schools" },
    { icon: "⚙️", label: "Setup" },
    { icon: "🔒", label: "Constraints" },
    { icon: "📅", label: "Schedule" },
    { icon: "⚙", label: "Settings" },
  ];

  function handleEdit(school) {
    setSelectedSchool(school.id);
    setActiveNav("Setup");
    console.log("Editing setup for school", school.id);
  }

  return (
    <div style={{
      minHeight: "100vh",
      background: "#0b0d14",
      display: "flex", alignItems: "center", justifyContent: "center",
      fontFamily: "DM Sans, sans-serif",
    }}>
      <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />

      {/* Phone frame */}
      <div style={{
        width: 390, height: 844,
        background: "#0f1118",
        borderRadius: 50,
        border: "10px solid #1e2030",
        boxShadow: "0 40px 120px rgba(0,0,0,0.8), 0 0 0 1px rgba(255,255,255,0.05), inset 0 0 0 1px rgba(255,255,255,0.03)",
        overflow: "hidden",
        position: "relative",
        display: "flex", flexDirection: "column",
      }}>
        {/* Ambient glow top */}
        <div style={{
          position: "absolute", top: -60, left: "50%", transform: "translateX(-50%)",
          width: 300, height: 200,
          background: "radial-gradient(ellipse, rgba(108,99,255,0.25) 0%, transparent 70%)",
          pointerEvents: "none",
        }} />

        {/* Status bar */}
        <div style={{ padding: "14px 24px 0", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
          <span style={{ color: "#e2e8f0", fontSize: 13, fontWeight: 700 }}>9:41</span>
          <div style={{
            width: 120, height: 28, background: "#0f1118",
            borderRadius: 20, border: "2px solid #1e2030",
            position: "absolute", left: "50%", transform: "translateX(-50%)",
            top: 14,
          }} />
          <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
            <span style={{ fontSize: 12 }}>📶</span>
            <span style={{ fontSize: 12 }}>🔋</span>
          </div>
        </div>

        {/* Scrollable content */}
        <div style={{ flex: 1, overflowY: "auto", padding: "16px 20px 0", scrollbarWidth: "none" }}>

          {/* Header */}
          <div style={{
            display: "flex", justifyContent: "space-between", alignItems: "center",
            marginBottom: 22,
            opacity: mounted ? 1 : 0,
            transform: mounted ? "none" : "translateY(12px)",
            transition: "all 0.5s cubic-bezier(.4,0,.2,1)",
          }}>
            <div>
              <div style={{ color: "#64748b", fontSize: 12, fontWeight: 600, letterSpacing: "0.06em", textTransform: "uppercase" }}>
                Good morning 👋
              </div>
              <div style={{ color: "#f1f5f9", fontSize: 26, fontWeight: 900, fontFamily: "Playfair Display, serif", lineHeight: 1.1 }}>
                ClassScheduler
              </div>
            </div>
            <div style={{
              width: 42, height: 42, borderRadius: 14,
              background: "linear-gradient(135deg, #6C63FF, #A78BFA)",
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 20, boxShadow: "0 4px 16px rgba(108,99,255,0.5)",
              cursor: "pointer",
            }}>
              +
            </div>
          </div>

          {/* Trial banner */}
          {showTrial && (
            <div style={{
              background: "linear-gradient(135deg, rgba(108,99,255,0.2), rgba(167,139,250,0.1))",
              border: "1px solid rgba(108,99,255,0.3)",
              borderRadius: 14, padding: "12px 14px",
              display: "flex", alignItems: "center", gap: 10,
              marginBottom: 20,
              opacity: mounted ? 1 : 0,
              transform: mounted ? "none" : "translateY(10px)",
              transition: "all 0.6s cubic-bezier(.4,0,.2,1) 0.1s",
            }}>
              <span style={{ fontSize: 20 }}>✨</span>
              <div style={{ flex: 1 }}>
                <div style={{ color: "#a78bfa", fontSize: 12, fontWeight: 700, fontFamily: "DM Sans, sans-serif" }}>
                  Trial — 1 free generation remaining
                </div>
                <div style={{ color: "#64748b", fontSize: 10, marginTop: 1 }}>Subscribe for unlimited access</div>
              </div>
              <div
                onClick={() => setShowTrial(false)}
                style={{ color: "#64748b", cursor: "pointer", fontSize: 16, lineHeight: 1 }}>×</div>
            </div>
          )}

          {/* Section title */}
          <div style={{
            color: "#94a3b8", fontSize: 11, fontWeight: 700, letterSpacing: "0.1em",
            textTransform: "uppercase", marginBottom: 14,
            opacity: mounted ? 1 : 0,
            transition: "opacity 0.5s ease 0.15s",
          }}>
            Your Schools ({schools.length})
          </div>

          {/* School cards */}
          <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
            {schools.map((school, i) => (
              <div key={school.id} style={{
                opacity: mounted ? 1 : 0,
                transform: mounted ? "none" : "translateY(20px)",
                transition: `all 0.55s cubic-bezier(.4,0,.2,1) ${0.2 + i * 0.08}s`,
              }}>
                <SchoolCard school={school} index={i} onEdit={handleEdit} />
              </div>
            ))}
          </div>

          {/* Add school */}
          <div style={{
            border: "1.5px dashed rgba(255,255,255,0.1)",
            borderRadius: 20, padding: "18px 24px",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 10,
            cursor: "pointer", marginTop: 14, marginBottom: 24,
            opacity: mounted ? 0.6 : 0,
            transition: "opacity 0.5s ease 0.45s",
          }}>
            <span style={{ color: "#64748b", fontSize: 20 }}>+</span>
            <span style={{ color: "#64748b", fontSize: 13, fontWeight: 600, fontFamily: "DM Sans, sans-serif" }}>Add a school</span>
          </div>
        </div>

        {/* Bottom navigation */}
        <div style={{
          background: "rgba(15,17,24,0.95)",
          backdropFilter: "blur(20px)",
          borderTop: "1px solid rgba(255,255,255,0.06)",
          display: "flex", justifyContent: "space-around",
          padding: "8px 0 20px",
        }}>
          {navItems.map(item => (
            <div key={item.label} onClick={() => setActiveNav(item.label)}>
              <NavItem icon={item.icon} label={item.label} active={activeNav === item.label} />
            </div>
          ))}
        </div>
      </div>

      {/* Outer ambient glow */}
      <div style={{
        position: "fixed", inset: 0, pointerEvents: "none", zIndex: -1,
        background: "radial-gradient(ellipse 80% 60% at 50% 50%, rgba(108,99,255,0.08) 0%, transparent 70%)",
      }} />
    </div>
  );
}
