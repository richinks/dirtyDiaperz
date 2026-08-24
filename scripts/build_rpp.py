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
