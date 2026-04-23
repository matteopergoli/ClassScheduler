import { useState } from "react";

const DAYS = ["Lun", "Mar", "Mer", "Gio", "Ven"];
const DAY_FULL = { Lun: "Lunedì", Mar: "Martedì", Mer: "Mercoledì", Gio: "Giovedì", Ven: "Venerdì" };
const SLOTS = [1,2,3,4,5,6,7,8];
const TIME = { 1:"08:00",2:"09:00",3:"10:00",4:"11:00",5:"12:00",6:"13:00",7:"14:00",8:"15:00" };

const TEACHER_COLORS = {
  Irene:   { bg: "#6C63FF", light: "rgba(108,99,255,0.18)", text: "#a78bfa" },
  Sofia:   { bg: "#F472B6", light: "rgba(244,114,182,0.18)", text: "#f9a8d4" },
  Alessia: { bg: "#34D399", light: "rgba(52,211,153,0.18)", text: "#6ee7b7" },
  Simone:  { bg: "#60A5FA", light: "rgba(96,165,250,0.18)", text: "#93c5fd" },
  Nora:    { bg: "#FBBF24", light: "rgba(251,191,36,0.18)", text: "#fde68a" },
};

const vincoli_empty = new Set([
  "KF-Lun-1","KF-Lun-7","KF-Lun-8",
  "KF-Mer-7","KF-Mer-8",
  "KF-Gio-7","KF-Gio-8",
  "KF-Ven-1","KF-Ven-2",
  "NA-Ven-6",
]);

// Best solution from solver
const schedule = {
  KF: {
    Lun: { 1:null,   2:"Alessia", 3:"Alessia", 4:"Alessia", 5:"Sofia",   6:"Sofia",   7:null,   8:null   },
    Mar: { 1:"Sofia",2:"Sofia",   3:"Sofia",   4:"Sofia",   5:"Alessia", 6:"Irene",   7:"Irene",8:"Irene" },
    Mer: { 1:"Alessia",2:"Alessia",3:"Irene",  4:"Irene",  5:"Irene",   6:"Irene",   7:null,   8:null   },
    Gio: { 1:"Irene",2:"Irene",   3:"Irene",   4:"Irene",  5:"Irene",   6:"Irene",   7:null,   8:null   },
    Ven: { 1:null,   2:null,      3:"Irene",   4:"Irene",  5:"Irene",   6:"Alessia", 7:"Irene",8:"Irene" },
  },
  NA: {
    Lun: { 1:"Irene",2:"Irene",   3:"Simone",  4:"Simone", 5:"Alessia", 6:"Simone",  7:"Simone",8:"Simone" },
    Mar: { 1:"Nora", 2:"Nora",    3:"Alessia", 4:"Alessia",5:"Simone",  6:"Simone",  7:"Sofia", 8:"Sofia"  },
    Mer: { 1:"Nora", 2:"Nora",    3:"Nora",    4:"Simone", 5:"Simone",  6:"Simone",  7:"Irene", 8:"Irene"  },
    Gio: { 1:"Alessia",2:"Alessia",3:"Alessia",4:"Sofia",  5:"Sofia",   6:"Sofia",   7:"Sofia", 8:"Sofia"  },
    Ven: { 1:"Nora", 2:"Alessia", 3:"Alessia", 4:"Alessia",5:"Alessia", 6:null,      7:"Sofia", 8:"Sofia"  },
  },
};

// Verify targets match solver output
const targets = {
  KF: { Irene:18, Sofia:6, Alessia:7, Simone:0, Nora:0 },
  NA: { Irene:4, Sofia:9, Alessia:10, Simone:10, Nora:6 },
};

const teacherStats = {};
Object.keys(TEACHER_COLORS).forEach(t => {
  let total = 0, byClass = {};
  ["KF","NA"].forEach(cls => {
    let n = 0;
    DAYS.forEach(d => SLOTS.forEach(s => { if(schedule[cls][d][s] === t) n++; }));
    byClass[cls] = n;
    total += n;
  });
  const daily = {};
  DAYS.forEach(d => {
    let n = 0;
    ["KF","NA"].forEach(cls => SLOTS.forEach(s => { if(schedule[cls][d][s] === t) n++; }));
    if(n > 0) daily[d] = n;
  });
  teacherStats[t] = { total, byClass, daily };
});

function isForced(cls, day, slot) {
  return vincoli_empty.has(`${cls}-${day}-${slot}`);
}

function Cell({ cls, day, slot }) {
  const [hov, setHov] = useState(false);
  const teacher = schedule[cls][day][slot];
  const forced = isForced(cls, day, slot);

  if (forced) return (
    <div style={{
      background: "rgba(255,255,255,0.02)", border: "1px dashed rgba(255,255,255,0.06)",
      borderRadius: 8, height: 36, display:"flex", alignItems:"center", justifyContent:"center",
    }}>
      <span style={{ color:"rgba(255,255,255,0.15)", fontSize:9, fontWeight:600, letterSpacing:"0.08em" }}>FREE</span>
    </div>
  );

  if (!teacher) return (
    <div style={{
      background: "rgba(255,255,255,0.02)", border: "1px solid rgba(255,255,255,0.04)",
      borderRadius: 8, height: 36,
    }} />
  );

  const col = TEACHER_COLORS[teacher];
  return (
    <div
      onMouseEnter={() => setHov(true)}
      onMouseLeave={() => setHov(false)}
      style={{
        background: hov ? col.bg : col.light,
        border: `1px solid ${hov ? col.bg : "transparent"}`,
        borderRadius: 8, height: 36,
        display:"flex", alignItems:"center", justifyContent:"center",
        cursor:"default", transition:"all 0.15s ease",
        boxShadow: hov ? `0 0 12px ${col.bg}60` : "none",
      }}
    >
      <span style={{ color: col.text, fontSize: 11, fontWeight: 700, fontFamily:"DM Sans,sans-serif" }}>
        {teacher}
      </span>
    </div>
  );
}

function ClassGrid({ cls }) {
  return (
    <div>
      {/* Header row */}
      <div style={{ display:"grid", gridTemplateColumns:"52px repeat(5, 1fr)", gap:4, marginBottom:4 }}>
        <div />
        {DAYS.map(d => (
          <div key={d} style={{
            textAlign:"center", color:"#94a3b8", fontSize:10, fontWeight:700,
            letterSpacing:"0.08em", textTransform:"uppercase", fontFamily:"DM Sans,sans-serif", padding:"4px 0",
          }}>{d}</div>
        ))}
      </div>
      {/* Slot rows */}
      {SLOTS.map(slot => (
        <div key={slot} style={{ display:"grid", gridTemplateColumns:"52px repeat(5, 1fr)", gap:4, marginBottom:4 }}>
          <div style={{
            display:"flex", alignItems:"center", justifyContent:"flex-end", paddingRight:8,
            color:"#475569", fontSize:10, fontWeight:600, fontFamily:"DM Sans,sans-serif",
          }}>{TIME[slot]}</div>
          {DAYS.map(d => <Cell key={d} cls={cls} day={d} slot={slot} />)}
        </div>
      ))}
    </div>
  );
}

function TeacherPill({ name }) {
  const col = TEACHER_COLORS[name];
  const stats = teacherStats[name];
  return (
    <div style={{
      background: col.light, border: `1px solid ${col.bg}40`,
      borderRadius: 12, padding: "10px 14px",
      display:"flex", alignItems:"center", gap:10,
    }}>
      <div style={{ width:8, height:8, borderRadius:"50%", background:col.bg, boxShadow:`0 0 8px ${col.bg}` }} />
      <div style={{ flex:1 }}>
        <div style={{ color:col.text, fontSize:12, fontWeight:700, fontFamily:"DM Sans,sans-serif" }}>{name}</div>
        <div style={{ color:"#64748b", fontSize:10, fontFamily:"DM Sans,sans-serif", marginTop:1 }}>
          KF: {stats.byClass.KF}h · NA: {stats.byClass.NA}h · Total: {stats.total}h
        </div>
      </div>
      <div style={{ display:"flex", gap:4 }}>
        {Object.entries(stats.daily).map(([d,n]) => (
          <div key={d} style={{
            background:`${col.bg}25`, borderRadius:6, padding:"2px 6px",
            color:col.text, fontSize:9, fontWeight:700, fontFamily:"DM Sans,sans-serif",
          }}>{d} {n}h</div>
        ))}
      </div>
    </div>
  );
}

export default function App() {
  const [activeClass, setActiveClass] = useState("KF");

  return (
    <div style={{
      minHeight:"100vh", background:"#0b0d14",
      display:"flex", alignItems:"center", justifyContent:"center",
      padding: 24, fontFamily:"DM Sans,sans-serif",
    }}>
      <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet" />

      <div style={{ width:"100%", maxWidth:820 }}>

        {/* Header */}
        <div style={{ marginBottom:28, display:"flex", justifyContent:"space-between", alignItems:"flex-end" }}>
          <div>
            <div style={{ color:"#64748b", fontSize:11, fontWeight:600, letterSpacing:"0.1em", textTransform:"uppercase", marginBottom:4 }}>
              ClassScheduler · Generated result
            </div>
            <div style={{ color:"#f1f5f9", fontSize:28, fontWeight:900, fontFamily:"Playfair Display,serif" }}>
              Orario Settimanale
            </div>
          </div>
          {/* Quality badge */}
          <div style={{
            background:"linear-gradient(135deg, rgba(16,185,129,0.2), rgba(16,185,129,0.08))",
            border:"1px solid rgba(16,185,129,0.35)", borderRadius:16,
            padding:"10px 18px", textAlign:"center",
          }}>
            <div style={{ color:"#10b981", fontSize:26, fontWeight:900, fontFamily:"DM Sans,sans-serif", lineHeight:1 }}>92</div>
            <div style={{ color:"#6ee7b7", fontSize:10, fontWeight:600, letterSpacing:"0.06em", marginTop:2 }}>QUALITY</div>
            <div style={{ display:"flex", alignItems:"center", justifyContent:"center", gap:5, marginTop:4 }}>
              <div style={{ width:6, height:6, borderRadius:"50%", background:"#10b981" }} />
              <span style={{ color:"#10b981", fontSize:10, fontWeight:700 }}>Zero violations</span>
            </div>
          </div>
        </div>

        {/* Class tabs */}
        <div style={{ display:"flex", gap:8, marginBottom:20 }}>
          {["KF","NA"].map(cls => (
            <button key={cls} onClick={() => setActiveClass(cls)} style={{
              background: activeClass === cls
                ? "linear-gradient(135deg, #6C63FF, #A78BFA)"
                : "rgba(255,255,255,0.04)",
              border: activeClass === cls ? "none" : "1px solid rgba(255,255,255,0.08)",
              borderRadius:12, padding:"8px 24px",
              color: activeClass === cls ? "#fff" : "#64748b",
              fontSize:13, fontWeight:700, fontFamily:"DM Sans,sans-serif",
              cursor:"pointer", transition:"all 0.2s ease",
              boxShadow: activeClass === cls ? "0 4px 16px rgba(108,99,255,0.4)" : "none",
            }}>
              Classe {cls}
            </button>
          ))}
          <div style={{ marginLeft:"auto", display:"flex", alignItems:"center", gap:6 }}>
            {Object.entries(TEACHER_COLORS).map(([name, col]) => (
              <div key={name} style={{
                display:"flex", alignItems:"center", gap:4,
                background: col.light, borderRadius:20, padding:"4px 10px",
              }}>
                <div style={{ width:5, height:5, borderRadius:"50%", background:col.bg }} />
                <span style={{ color:col.text, fontSize:10, fontWeight:700, fontFamily:"DM Sans,sans-serif" }}>{name}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Grid */}
        <div style={{
          background:"rgba(255,255,255,0.02)", border:"1px solid rgba(255,255,255,0.07)",
          borderRadius:20, padding:20, marginBottom:20,
        }}>
          <ClassGrid cls={activeClass} />
        </div>

        {/* Teacher summary */}
        <div style={{ marginBottom:8 }}>
          <div style={{ color:"#64748b", fontSize:11, fontWeight:700, letterSpacing:"0.1em", textTransform:"uppercase", marginBottom:12 }}>
            Teacher Summary
          </div>
          <div style={{ display:"flex", flexDirection:"column", gap:8 }}>
            {Object.keys(TEACHER_COLORS).map(name => (
              <TeacherPill key={name} name={name} />
            ))}
          </div>
        </div>

        {/* Footer note */}
        <div style={{
          marginTop:20, padding:"12px 16px",
          background:"rgba(16,185,129,0.06)", border:"1px solid rgba(16,185,129,0.15)",
          borderRadius:12, display:"flex", alignItems:"center", gap:10,
        }}>
          <span style={{ fontSize:16 }}>✅</span>
          <span style={{ color:"#6ee7b7", fontSize:12, fontWeight:600, fontFamily:"DM Sans,sans-serif" }}>
            All hard constraints satisfied · F1 teacher gaps = 15 · F2 subject changes = 16
          </span>
        </div>
      </div>
    </div>
  );
}
