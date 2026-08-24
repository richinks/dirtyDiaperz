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
