local script_path = "C:\\dirty-diaperz-automation\\run_dirty_diaperz.bat"

reaper.ShowConsoleMsg("Running Dirty Diaperz automation...\n")
os.execute('"' .. script_path .. '"')
reaper.ShowConsoleMsg("Automation complete.\n")
