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
