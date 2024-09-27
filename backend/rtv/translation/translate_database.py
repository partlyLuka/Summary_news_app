from slo_to_eng import english
import json
from tqdm import tqdm
import concurrent.futures
import threading

timeout = 180

data_path = "data/rtv.json"
rubrics = ["slovenija", "sport", "svet", "kultura", "zabava-in-slog"]

def translate():
    for rubric in rubrics:
        print("Translating the rubric: ", rubric)
        with open(data_path, "r", encoding="utf-8") as file:
            rtv = json.load(file)
        
        for date in tqdm(rtv[rubric], desc="Dates", leave=False):
            
            for i in tqdm(range(len(rtv[rubric][date])), desc="Articles", leave=False):
                
                article = rtv[rubric][date][i]
                
                if "english_content" not in article:
                    
                    content = article["content"]
                    #The following code is here because we have only one poor cpu, which can be used....
                    if len(content.split()) < 2000: 
                    
                        english_content = english(content)
                    else:
                        english_content = "Content was too long to translate."
                    title = article["title"]
                    english_title = english(title)
                    

                    rtv[rubric][date][i]["english_content"] = english_content
                    rtv[rubric][date][i]["english_title"] = english_title
        
            with open(data_path, "w", encoding="utf-8") as file:
                json.dump(rtv, file)

    # Ensure that all threads are properly cleaned up
    for thread in threading.enumerate():
        if thread is not threading.main_thread():
            thread.join(timeout=1)


if __name__ == "__main__":
    translate()
