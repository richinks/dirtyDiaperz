import React, { useState } from "react";

export default function UploadSong() {
  const [message, setMessage] = useState("");

  const upload = async (e) => {
    const file = e.target.files[0];
    const formData = new FormData();
    formData.append("file", file);

    const res = await fetch("/api/upload", {
      method: "POST",
      body: formData
    });

    const json = await res.json();
    setMessage(json.message);
  };

  return (
    <div>
      <h2>Upload Song</h2>
      <input type="file" onChange={upload} />
      <p>{message}</p>
    </div>
  );
}
