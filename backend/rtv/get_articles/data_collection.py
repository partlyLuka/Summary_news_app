from gather_data import update_database
import json
import time
data_path = "data/rtv.json" 

rubrics = ["slovenija", "sport", "svet", "kultura", "zabava-in-slog"]
def update(rubric, start, end, time_delta):

    print("Updating the rubric :", rubric)
    with open(data_path, "r", encoding="utf-8") as file:
        rtv = json.load(file)
    
    update_database(rtv, rubric, start, end, time_delta)
    
    with open(data_path, "w", encoding="utf-8") as file:
        json.dump(rtv, file)
    print("Updated the rubric:", rubric)
    
    print("Sleeping for 10 seconds...")
    time.sleep(10)

if __name__ == "__main__":
    for rubric in rubrics:
        update(rubric, 0, 2, 1.0)