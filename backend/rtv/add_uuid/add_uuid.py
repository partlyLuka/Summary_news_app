import uuid
import json

data_path = "data/rtv.json"

with open(data_path, "r", encoding="utf-8") as file:
    rtv = json.load(file)

def add_uuid():
    all_uuids = []
    for rubric in rtv:
        for date in rtv[rubric]:
            for i in range(len(rtv[rubric][date])):
                article = rtv[rubric][date][i]
                try:
                    this_uuid = article["uuid"]
                    all_uuids.append(this_uuid)
                except KeyError:
                    continue


    for rubric in rtv:
        for date in rtv[rubric]:
            for i in range(len(rtv[rubric][date])):
                article = rtv[rubric][date][i]
                if not "uuid" in article:
                    new_uuid = str(uuid.uuid4())
                    while new_uuid in all_uuids:
                        new_uuid = uuid.uuid()
                    article["uuid"] = new_uuid
                    rtv[rubric][date][i] = article
    with open(data_path, "w", encoding="utf-8") as file:
        json.dump(rtv, file) 
        
