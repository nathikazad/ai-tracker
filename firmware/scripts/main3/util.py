from datetime import datetime
previouse_time = datetime.now()
def log(message):
    global previouse_time
    diff_ms = int((datetime.now() - previouse_time).total_seconds() * 1000)
    # current_time = datetime.now().strftime("%S.%f")[:-3]
    print(f"[{diff_ms}]: {message}")
    previouse_time = datetime.now()

def clear_previous_time():
    global previouse_time
    previouse_time = datetime.now()