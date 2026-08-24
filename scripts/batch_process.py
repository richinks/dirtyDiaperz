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
