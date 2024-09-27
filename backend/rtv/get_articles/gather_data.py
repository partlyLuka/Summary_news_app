import numpy
import os 
import requests
import traceback
import time
from selenium import webdriver
import re 
import json
import validators
from tqdm import tqdm

from selenium import webdriver
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options

firefox_options = Options()
firefox_options.add_argument("--headless")  # Run Firefox in headless mode
driver = webdriver.Firefox(options=firefox_options)

from article_data import article_html_to_data, fix

def get_html(url):
    driver.get(url)
    content = driver.page_source
    return content

v_naslov_datum_url = r'<div class="article-archive-item" date-is="(?P<datum>.+?)">.+?<div class="md-news">.+?<a href="(?P<url>.+?)" class=".+?" title=(?P<naslov>.+?)>'

def dobi_naslov_cas_url_izarhiva_rtv(html):
    """Funkcija, ki iz datoteke 'vhod', ki je html arhiva rtv, izlusci naslov, cas objave in url clankov. Vrne ustrezen slovar, čigar kljuci so naslovi"""
    clanki = {}
    
    for najdba in re.finditer(v_naslov_datum_url, html, flags=re.DOTALL):
        cas = najdba["datum"]
        naslov = najdba["naslov"]
        naslov = naslov.strip('"')
        link ="https://www.rtvslo.si" + najdba["url"]
        
        if "=" in naslov:
            naslov = fix(naslov)
        clanki[naslov] = {"date" : cas, "url" : link}
      
    return clanki


rtv_articles = {}


months = {
    "januar" : "01", 
    "februar" : "02",
    "marec" : "03",
    "april" : "04",
    "maj" : "05", 
    "junij" : "06", 
    "julij" : "07",
    "avgust" : "08", 
    "september" : "09", 
    "oktober" : "10", 
    "november" : "11", 
    "december" : "12"
}

def insert_ordered(ordered_list, new_dict):
    # Find the position where the new dictionary should be inserted
    for i, existing_dict in enumerate(ordered_list):
        if float(new_dict['time']) > float(existing_dict['time']):
            ordered_list.insert(i, new_dict)
            break
    else:
        # If the loop completes without finding a place, append at the end
        ordered_list.append(new_dict)

# E
miss = 0 
def update_database(db, rubric, start, end, time_delta=0):
    "db is a json"
    if rubric not in db:
        db[rubric] = {}
        
    for i in tqdm(range(start, end)):
        url = f"https://www.rtvslo.si/{rubric}/arhiv/?&page={i}"
        html = get_html(url)
        new_articles = dobi_naslov_cas_url_izarhiva_rtv(html)
        for article in new_articles:
            date = new_articles[article]["date"]
            day, month, year = date.split()
            date = year + "-" + months[month] + "-" + day[:-1]
            
            if not date in db[rubric]:
                db[rubric][date] = [] #it is a list...
            if "=" in article:
                fixed_title = fix(article)
            else:
                fixed_title = article
            title_list = [x["title"] for x in db[rubric][date]]
            if not fixed_title in title_list:
                url = new_articles[article]["url"]
                html = get_html(url)
                data = article_html_to_data(html)
                
                try:
                    clock  = data["time"]
                except KeyError:
                    continue
                    
                clock = clock.split()
                clock = clock[-1]
                data["time"] = clock
                data["title"] = fixed_title
                
                insert_ordered(db[rubric][date], data)
                
                
                #db[rubric][date][fixed_title] = data
            time.sleep(time_delta)

                

