import datetime

LOGFILE = "automation.log"

def log(msg):
    timestamp = datetime.datetime.now().strftime("[%Y-%m-%d %H:%M:%S]")
    with open(LOGFILE, "a") as f:
        f.write(f"{timestamp} {msg}\n")
    print(msg)
