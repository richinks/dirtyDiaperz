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
