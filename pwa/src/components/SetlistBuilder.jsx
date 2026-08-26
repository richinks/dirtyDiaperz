import React, { useEffect, useState } from "react";

export default function SetlistBuilder() {
  const [songs, setSongs] = useState([]);
  const [setlist, setSetlist] = useState([]);

  useEffect(() => {
    fetch("/config/setlist.json")
      .then((res) => res.json())
      .then((data) => setSongs(data.songs));
  }, []);

  const addToSetlist = (song) => {
    setSetlist([...setlist, song]);
  };

  return (
    <div>
      <h2>Setlist Builder</h2>

      <h3>Available Songs</h3>
      <ul>
        {songs.map((song) => (
          <li key={song}>
            {song} <button onClick={() => addToSetlist(song)}>Add</button>
          </li>
        ))}
      </ul>

      <h3>Current Setlist</h3>
      <ol>
        {setlist.map((song, i) => (
          <li key={i}>{song}</li>
        ))}
      </ol>
    </div>
  );
}
