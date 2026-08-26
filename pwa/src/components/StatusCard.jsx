import React from "react";

export default function StatusCard({ title, status }) {
  return (
    <div style={{ padding: 10, background: "#222", marginBottom: 10, borderRadius: 6 }}>
      <strong>{title}</strong>: {status}
    </div>
  );
}
