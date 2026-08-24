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
