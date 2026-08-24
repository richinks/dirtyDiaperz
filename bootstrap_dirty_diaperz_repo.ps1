# Dirty Diaperz Automation Repo Bootstrap Script
# Creates full folder structure and populates all files

Write-Host "Bootstrapping Dirty Diaperz automation repo..."

# --- Create folders ---
$folders = @(
    "config",
    "incoming",
    "stems",
    "click",
    "cues",
    "reaper-projects",
    "scripts",
    "reaper",
    "reaper\reascripts",
    "reaper\docs"
)

foreach ($f in $folders) {
    New-Item -ItemType Directory -Force -Path $f | Out-Null
}

# --- Create .gitignore ---
@"
__pycache__/
*.pyc
.env
automation.log
incoming/
stems/
click/
cues/
reaper-projects/
dist/
build/
installer/
"@ | Set-Content ".gitignore"

# --- Create requirements.txt ---
@"
demucs
librosa
soundfile
numpy
TTS
"@ | Set-Content "requirements.txt"

# --- Create README.md ---
@"
# Dirty Diaperz Automation

End-to-end REAPER show-file automation for Dirty Diaperz:

- Demucs stem splitting
- Automatic BPM + tempo map
- Click track generation
- Voice cue track generation
- Auto-generated REAPER projects
- Batch processing
- REAPER integration scripts

## Usage

1. Install dependencies:

   pip install -r requirements.txt

2. Drop a .wav or .mp3 into incoming/

3. Run:

   python scripts/dirty_diaperz_fadr.py

4. Open the generated .RPP from reaper-projects/ in REAPER.
"@ | Set-Content "README.md"

# --- Create config/settings.json ---
@"
{
  "incoming_dir": "incoming",
  "stems_dir": "stems",
  "click_dir": "click",
  "cues_dir": "cues",
  "rpp_dir": "reaper-projects",
  "sample_rate": 44100
}
"@ | Set-Content "config/settings.json"

# --- Create config/song_bible_schema.json ---
@"
{
  "type": "object",
  "properties": {
    "song": { "type": "string" },
    "artist": { "type": "string" },
    "recording_bpm": { "type": "number" },
    "drummer_click_bpm": { "type": "number" },
    "time_signature": { "type": "string" },
    "feel": { "type": "string" },
    "key": { "type": "string" },
    "duration_seconds": { "type": "number" },
    "count_in": { "type": "number" },
    "backing_track": { "type": "boolean" },
    "voice_cue": { "type": "boolean" },
    "reaper_status": { "type": "string" },
    "x32_scene_status": { "type": "string" },
    "source_sheets": { "type": "string" },
    "notes": { "type": "string" }
  },
  "required": [
    "song",
    "artist",
    "recording_bpm",
    "time_signature",
    "key",
    "duration_seconds"
  ]
}
"@ | Set-Content "config/song_bible_schema.json"

# --- Create config/setlist.json ---
@"
{
  "setlist": ["Back in Black", "Pamela", "Africa"],
  "durations": {
    "Back in Black": 257,
    "Pamela": 240,
    "Africa": 295
  }
}
"@ | Set-Content "config/setlist.json"

# --- Create config/routing.json ---
@"
{
  "buses": {
    "iem": "IEM Bus",
    "cue": "Cue Bus",
    "foh": "FOH Bus"
  },
  "routing_rules": {
    "Click": "iem",
    "Cue": "cue",
    "Drums": "foh",
    "Bass": "foh",
    "Vocals": "foh",
    "Other": "foh",
    "Tracking": "foh"
  }
}
"@ | Set-Content "config/routing.json"

# --- Create scripts/dirty_diaperz_fadr.py ---
@"
import os
import glob
import sys
from demucs_pipeline import run_demucs
from tempo_map import detect_tempo_and_beats, build_click_from_beats
from voice_cues import generate_voice_cue_track
from build_rpp import build_rpp

INCOMING = "incoming"
CLICK_DIR = "click"
CUES_DIR = "cues"
RPP_DIR = "reaper-projects"

def find_latest_audio():
    files = glob.glob(os.path.join(INCOMING, "*.wav")) + \
            glob.glob(os.path.join(INCOMING, "*.mp3"))
    if not files:
        print("[AutoRun] No audio files found in incoming/")
        sys.exit(1)
    return max(files, key=os.path.getmtime)

def auto_run():
    print("[AutoRun] Starting Dirty Diaperz automation…")

    audio_file = find_latest_audio()
    song_name = os.path.splitext(os.path.basename(audio_file))[0]

    print(f"[AutoRun] Found audio: {audio_file}")
    print(f"[AutoRun] Song name detected: {song_name}")

    stems_folder = run_demucs(audio_file)

    tempo, beats = detect_tempo_and_beats(audio_file)

    os.makedirs(CLICK_DIR, exist_ok=True)
    click_file = os.path.join(CLICK_DIR, f"{song_name}.wav")
    build_click_from_beats(beats, click_file)

    os.makedirs(CUES_DIR, exist_ok=True)
    cue_file = os.path.join(CUES_DIR, f"{song_name}.wav")

    sections = [
        {"name": "Song Start", "time": 0.0},
        {"name": "Chorus", "time": 60.0}
    ]

    generate_voice_cue_track(sections, cue_file)

    os.makedirs(RPP_DIR, exist_ok=True)
    build_rpp(song_name, stems_folder, click_file, cue_file)

    print("[AutoRun] COMPLETE — REAPER project generated successfully.")

if __name__ == "__main__":
    auto_run()
"@ | Set-Content "scripts/dirty_diaperz_fadr.py"

# --- Create scripts/demucs_pipeline.py ---
@"
import subprocess
import os

def run_demucs(input_file, output_root="stems"):
    song_name = os.path.splitext(os.path.basename(input_file))[0]
    output_folder = os.path.join(output_root, song_name)

    os.makedirs(output_folder, exist_ok=True)

    print(f"[Demucs] Splitting stems for: {song_name}")

    subprocess.run([
        "demucs",
        input_file,
        "-o",
        output_root
    ], check=True)

    print(f"[Demucs] Finished. Stems saved to: {output_folder}")
    return output_folder
"@ | Set-Content "scripts/demucs_pipeline.py"

# --- Create scripts/tempo_map.py ---
@"
import librosa
import numpy as np
import soundfile as sf

def detect_tempo_and_beats(audio_file):
    y, sr = librosa.load(audio_file)
    tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)
    print(f"[Tempo] BPM detected: {tempo:.2f}")
    return tempo, beat_times

def build_click_from_beats(beat_times, output_file, sr=44100):
    if len(beat_times) == 0:
        raise ValueError("No beats detected")

    duration = beat_times[-1] + 4
    total_samples = int(duration * sr)
    click = np.zeros(total_samples)

    blip_freq = 1000
    blip_len = int(0.02 * sr)
    t = np.linspace(0, 1, blip_len)
    blip = 0.8 * np.sin(2 * np.pi * blip_freq * t)

    for bt in beat_times:
        idx = int(bt * sr)
        if idx + blip_len < total_samples:
            click[idx:idx+blip_len] += blip

    sf.write(output_file, click, sr)
    print(f"[Click] Created tempo-mapped click: {output_file}")
    return output_file
"@ | Set-Content "scripts/tempo_map.py"

# --- Create scripts/voice_cues.py ---
@"
from TTS.api import TTS
import soundfile as sf
import numpy as np

tts = TTS("tts_models/en/ljspeech/tacotron2-DDC")

def tts_to_array(text, sr=22050):
    audio = tts.tts(text)
    return np.array(audio), sr

def generate_voice_cue_track(sections, output_file):
    sr = 22050
    total_duration = max(s["time"] for s in sections) + 10
    total_samples = int(total_duration * sr)
    track = np.zeros(total_samples)

    for s in sections:
        text = f"{s['name']} in two, three, four"
        audio, sr_local = tts_to_array(text, sr=sr)
        start_idx = int(s["time"] * sr)
        end_idx = start_idx + len(audio)
        if end_idx > total_samples:
            end_idx = total_samples
        track[start_idx:end_idx] += audio[: end_idx - start_idx]

    sf.write(output_file, track, sr)
    print(f"[VoiceCue] Created voice cue track: {output_file}")
    return output_file
"@ | Set-Content "scripts/voice_cues.py"

# --- Create scripts/build_rpp.py ---
@"
import os

def track_block(name, file_path):
    return f'''
<TRACK
  NAME "{name}"
  <ITEM
    FILE "{file_path}"
  >
>
'''

def build_rpp(song_name, stems_folder, click_file, cue_file, output_folder="reaper-projects"):
    os.makedirs(output_folder, exist_ok=True)
    rpp_path = os.path.join(output_folder, f"{song_name}.RPP")

    drums = os.path.join(stems_folder, "drums.wav")
    bass = os.path.join(stems_folder, "bass.wav")
    vocals = os.path.join(stems_folder, "vocals.wav")
    other = os.path.join(stems_folder, "other.wav")

    rpp = f'''
<REAPER_PROJECT
  VERSION 1.0
  SONG "{song_name}"
>

{track_block("Drums", drums)}
{track_block("Bass", bass)}
{track_block("Vocals", vocals)}
{track_block("Other", other)}
{track_block("Click", click_file)}
{track_block("Cue", cue_file)}
{track_block("Tracking", "")}
'''

    with open(rpp_path, "w") as f:
        f.write(rpp)

    print(f"[RPP] Created REAPER project: {rpp_path}")
    return rpp_path
"@ | Set-Content "scripts/build_rpp.py"

# --- Create scripts/logger.py ---
@"
import datetime

LOGFILE = "automation.log"

def log(msg):
    timestamp = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    with open(LOGFILE, "a") as f:
        f.write(f"{timestamp} {msg}\n")
    print(msg)
"@ | Set-Content "scripts/logger.py"

# --- Create scripts/batch_process.py ---
@"
import os
import glob
from demucs_pipeline import run_demucs
from tempo_map import detect_tempo_and_beats, build_click_from_beats
from voice_cues import generate_voice_cue_track
from build_rpp import build_rpp

def process_song(audio_file):
    song_name = os.path.splitext(os.path.basename(audio_file))[0]
    print(f"[Batch] Processing {song_name}")

    stems_folder = run_demucs(audio_file)

    tempo, beats = detect_tempo_and_beats(audio_file)
    click_file = f"click/{song_name}.wav"
    build_click_from_beats(beats, click_file)

    sections = [
        {"name": "Song Start", "time": 0.0},
        {"name": "Chorus", "time": 60.0}
    ]
    cue_file = f"cues/{song_name}.wav"
    generate_voice_cue_track(sections, cue_file)

    build_rpp(song_name, stems_folder, click_file, cue_file)

def batch_process(folder="incoming/setlist"):
    files = glob.glob(os.path.join(folder, "*.wav")) + \
            glob.glob(os.path.join(folder, "*.mp3"))
    for f in files:
        process_song(f)

if __name__ == "__main__":
    batch_process()
"@ | Set-Content "scripts/batch_process.py"

# --- Create REAPER scripts ---
@"
local script_path = "C:\\dirty-diaperz-automation\\run_dirty_diaperz.bat"

reaper.ShowConsoleMsg("Running Dirty Diaperz automation...\n")
os.execute('"' .. script_path .. '"')
reaper.ShowConsoleMsg("Automation complete.\n")
"@ | Set-Content "reaper/reascripts/reaper_run_dirty_diaperz.lua"

@"
function create_bus(name)
  reaper.InsertTrackInProject(-1, true)
  local track = reaper.GetTrack(0, reaper.CountTracks(0)-1)
  reaper.GetSetMediaTrackInfo_String(track, "P_NAME", name, true)
  return track
end

iem_bus = create_bus("IEM Bus")
cue_bus = create_bus("Cue Bus")
foh_bus = create_bus("FOH Bus")

local track_count = reaper.CountTracks(0)
for i = 0, track_count-1 do
  local track = reaper.GetTrack(0, i)
  _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

  if name:find("Click") then
    reaper.CreateTrackSend(track, iem_bus)
  elseif name:find("Cue") then
    reaper.CreateTrackSend(track, cue_bus)
  else
    reaper.CreateTrackSend(track, foh_bus)
  end
end
"@ | Set-Content "reaper/reascripts/setup_routing.lua"

@"
local track_count = reaper.CountTracks(0)

for i = 0, track_count-1 do
  local track = reaper.GetTrack(0, i)
  _, name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)

  if name:find("Click") then
    local item_count = reaper.CountTrackMediaItems(track)
    for j = 0, item_count-1 do
      local item = reaper.GetTrackMediaItem(track, j)
      local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
      reaper.AddProjectMarker(0, true, pos, 0, name, -1)
    end
  end
end
"@ | Set-Content "reaper/reascripts/add_markers.lua"

@"
# REAPER Integration Documentation

This folder contains Lua scripts that integrate Dirty Diaperz automation directly into REAPER.

- reaper_run_dirty_diaperz.lua
- setup_routing.lua
- add_markers.lua

Place these into:
REAPER/ResourcePath/UserPlugins/Scripts/
"@ | Set-Content "reaper/docs/reaper_integration.md"

Write-Host "Repo populated successfully!"
