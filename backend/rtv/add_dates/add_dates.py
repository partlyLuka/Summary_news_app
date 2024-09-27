import uuid
import json

data_path = "data/rtv.json"

with open(data_path, "r", encoding="utf-8") as file:
    rtv = json.load(file)
def add_dates():
    for rubric in rtv:
        for date in rtv[rubric]:
            for i in range(len(rtv[rubric][date])):
                article = rtv[rubric][date][i]
                article["date"] = date
                rtv[rubric][date][i] = article
                
    with open(data_path, "w", encoding="utf-8") as file:
        json.dump(rtv, file) 
        
