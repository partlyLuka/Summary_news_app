from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import json
from datetime import datetime
import asyncio

import sys
sys.path.append("/Users/lukaandrensek/Documents/app/backend/rtv/get_articles")
sys.path.append("/Users/lukaandrensek/Documents/app/backend/rtv/translation")
sys.path.append("/Users/lukaandrensek/Documents/app/backend/rtv/summarisation")

from data_summarisation import get_this_weeks_summary, get_past_weeks_summary
from gather_data import update_database
from data_collection import update

from translate_database import translate

rtv_base = "data/rtv.json"
import os 



def remove_key(d, key_to_remove):
    # Use dictionary comprehension to create a new dictionary
    # without the specified key
    return {k: v for k, v in d.items() if k != key_to_remove}

class SimpleHTTPRequestHandler(BaseHTTPRequestHandler):

    def do_GET(self):
        # Parse query parameters
        parsed_path = urllib.parse.urlparse(self.path)
        path = parsed_path.path
        query_params = urllib.parse.parse_qs(parsed_path.query)
        
        print(parsed_path)
        
        
        if path == "/get":
            
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
            print(query_params)
            print("**************")
            a_uuid = query_params["uuid"][0]
            
            items = {}
            for rubric in rtv:
                for date in rtv[rubric]:
                    for i in range(len(rtv[rubric][date])):
                        article = rtv[rubric][date][i]
                        try:
                            
                            if article["uuid"] == a_uuid:
                                items = article
                        except KeyError:
                            continue
            if len(items) > 0 :
                print(f"Received GET request on path: {parsed_path.path}\n")
                response_content = f"{json.dumps(items)}"
                print(response_content)
                

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
            else:
                print(f"Received GET request on path: {parsed_path.path}\n")
                items = {"error" : "no matching uuid"}
                response_content = f"{json.dumps(items)}"
                print(response_content)
                

                # Send response
                self.send_response(404)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
            
        if path == "/retrieve":
            
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
        
            rubric, date, top, language = query_params["rubric"][0], query_params["date"][0], int(query_params["top"][0]), query_params["language"][0]
            print(rubric, date, top, language)
            if top == -1:
                top = len(rtv[rubric][date])
            try:
                items = [rtv[rubric][date][i] for i in range(min(top, len(rtv[rubric][date])))]
                if language == "slo":
                    items = [remove_key(d, "english_content") for d in items]
                    for d in items:
                        d["english_content"] = "..."
                elif language == "eng":
                    items = [remove_key(d, "content") for d in items]
                    for d in items:
                        d["content"] = "..."
                print(f"Received GET request on path: {parsed_path.path}\n")
                response_content = f"{json.dumps(items)}"
                print(response_content)
                

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
            
            except KeyError:
                response_content = f"Received GET request on path: {parsed_path.path}\n"
                response_content += f"The queried parameters are not present in the databse."

                # Send response
                self.send_response(404)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
           
        if path == "/summary":
            
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
            #http://localhost:8080/summary?rubric=slovenija&sum_type=Past_week&week_number=0&language=eng
        
            rubric, sum_type, week_no, language = query_params["rubric"][0], query_params["sum_type"][0], int(query_params["week_number"][0]), query_params["language"][0]
            print(rubric, sum_type, week_no, language)
            if sum_type == "This_week":
                s = asyncio.run(get_this_weeks_summary(data=rtv, rubric=rubric, lang=language))
                
                response_content = s

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
            if sum_type == "Past_week":
                s = asyncio.run(get_past_weeks_summary(data=rtv, rubric=rubric, lang=language))
                
                response_content = s

                # Send response
                self.send_response(200)
                self.send_header('Content-Type', 'text/plain')
                self.end_headers()
                self.wfile.write(response_content.encode('utf-8'))
            
        
        if path == "/menu":
            
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
            items = {}
            for rubric in rtv:
                dates = [date for date in rtv[rubric]]
                dates = sorted(dates, key=lambda date: datetime.strptime(date, "%Y-%m-%d"))
                dates.reverse()
                items[rubric] = dates
    
                
            print(f"Received GET request on path: {parsed_path.path}\n")
            
            
            response_content = f"{json.dumps(items)}"

            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(response_content.encode('utf-8'))
                
        if path == "/menu/rubrics":
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
            rubrics = list(rtv.keys())
            
            response_content = f"Received GET request on path: {parsed_path.path}\n"
            
            items = {"rubrics": rubrics}
            
            response_content += f"The requested data : {json.dumps(items)}"

            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(response_content.encode('utf-8'))
        
        if path == "/menu/dates":
            with open(rtv_base, "r", encoding="utf-8") as file:
                rtv = json.load(file)
            dates = []
            for rubric in rtv:
                dates.extend(list(rtv[rubric].keys()))
            response_content = f"Received GET request on path: {parsed_path.path}\n"
            
            dates = list(set(dates))
            
            
            dates = sorted(dates, key=lambda date: datetime.strptime(date, "%Y-%m-%d"))
            dates.reverse()

            items = {"dates" : dates}
            print(items)
            response_content += f"The requested data : {json.dumps(items)}"

            # Send response
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain')
            self.end_headers()
            self.wfile.write(response_content.encode('utf-8'))
        
    
        
    def do_POST(self):
        # Get the length of the data
        content_length = int(self.headers['Content-Length'])

        # Read the data from the request
        post_data = self.rfile.read(content_length)

        # Parse JSON data if Content-Type is application/json
        if self.headers.get('Content-Type') == 'application/json':
            post_data = json.loads(post_data.decode('utf-8'))
            response_content = f"Received POST request with JSON data: {json.dumps(post_data)}"
        else:
            response_content = f"Received POST request with raw data: {post_data.decode('utf-8')}"

        # Send response
        self.send_response(200)
        self.send_header('Content-Type', 'text/plain')
        self.end_headers()
        self.wfile.write(response_content.encode('utf-8'))

def run(server_class=HTTPServer, handler_class=SimpleHTTPRequestHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting server on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
