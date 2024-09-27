import requests

def send_get_request():
    url = "http://ab5141ffd32e44.lhr.life/menu"
    params = {"rubric" : "sport", "sum_type" : "This_week", "week_number" : 10, "language" : "eng"}
#http://localhost:8080/summary?rubric=slovenija&sum_type=This_week&week_number=37&language=slo
    # Sending the GET request
    response = requests.get(url)
    
    # Printing the response from the server
    print("GET Request Response:")
    print(response.text)
    print("\n")

def send_post_request():
    url = "http://localhost:8080/menu"
    data = {"key": "value"}

    # Sending the POST request with JSON data
    response = requests.post(url, json=data)
    
    # Printing the response from the server
    print("POST Request Response:")
    print(response.text)

if __name__ == "__main__":
    # Send GET request
    send_get_request()

    # Send POST request
    #send_post_request()
