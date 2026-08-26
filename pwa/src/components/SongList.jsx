import React, { useEffect, useState } from "react";

export default function SongList() {
  const [songs, setSongs] = useState([]);

  useEffect(() => {
    fetch("/config/setlist.json")
      .then((res) => res.json())
      .then((data) => setSongs(data.songs));
  }, []);

  return (
    <div>
      <h2>Song Bible</h2>
      <ul>
        {songs.map((song) => (
          <li key={song}>{song}</li>
        ))}
      </ul>
    </div>
  );
}
