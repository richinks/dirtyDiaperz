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
