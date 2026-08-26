import React from "react";
import SongList from "./components/SongList";
import SetlistBuilder from "./components/SetlistBuilder";
import UploadSong from "./components/UploadSong";

export default function App() {
  return (
    <div style={{ padding: 20, fontFamily: "Arial", color: "#fff", background: "#111", minHeight: "100vh" }}>
      <h1>DirtyDiaperz Automation Dashboard</h1>

      <UploadSong />
      <SetlistBuilder />
      <SongList />
    </div>
  );
}
