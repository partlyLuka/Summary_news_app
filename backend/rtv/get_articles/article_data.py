import json
import os 
import re 
from selenium import webdriver

import validators
import requests
import time

v_avtor = r'name="author" content="(?P<avtor>.+?)">'
v_naslov = r'<meta name="title" content="(?P<nas>.+?)">'
v_cas = r'<div class="publish-meta">(?P<cas>.+?)<'
v_povzetek = r'<p class="lead">(?P<pov>.+?)</p>'
v_subtitle = r'<div class="subtitle">(?P<sub>.+?)</div>'
v_sirokovsebino = r'<article class="article">(?P<blok>.+?)</article>'
v_ozja_vsebina = r'<p>(.+?)</p>|<h\d>(.+?)</h\d>'

def article_html_to_data(text):
    pisi = ""
    data = {}
    
    for najdba in re.finditer(v_avtor, text, flags=re.DOTALL):
        
        avtor = najdba["avtor"]
        if najdba["avtor"]:
            data["author"] = avtor
        else:
            data["author"] = None
    for najdba in re.finditer(v_cas, text, flags=re.DOTALL):
        cas = najdba["cas"]
        if najdba["cas"]:
            data["time"] = cas.strip() 
        else:
            data["time"] = None   
    
    for n in re.finditer(v_naslov, text, flags=re.DOTALL):
        naslov = n["nas"]
    if not list(re.finditer(v_naslov, text, flags=re.DOTALL)):
        
        return None 
    pisi += naslov + "\n\n"
    for n in re.finditer(v_subtitle, text, flags=re.DOTALL):
        subtitle = n["sub"]
        if not "<" in subtitle:
            pisi += subtitle + "\n\n"
    for n in re.finditer(v_povzetek, text, flags=re.DOTALL):
        povzetek = n["pov"]
        if not "<" in povzetek:    
            pisi += povzetek + "\n\n"
    for n in re.finditer(v_sirokovsebino, text, flags=re.DOTALL):
        blook = n["blok"]
        if n["blok"]:
            for n in re.finditer(v_ozja_vsebina, blook, flags=re.DOTALL):
                vsebina = n.group()
                naivni_vzorec = r'<(.+?)>'
                vsebina = re.sub(naivni_vzorec, "", vsebina)
                if not "<" in vsebina:
                    pisi += vsebina + "\n\n"
    data["content"] = pisi
    return data

def fix(k):
    #ti imajo napako
    naslov = k.replace("=", "").replace(" ", "").replace('""', ' ').replace('"', '').capitalize()
    return naslov