# Summary news app

The inspiration for the project comes from:

1. The need for non-Slovene speakers, living in Slovenia, to be equally informed about current affairs as Slovene speakers are.
2. The idea to ease the ability to listen to news articles as opposed to just reading them
3. The possibility of generating personalised news, tailored for each individual, based on their interests and knowledge.
4. The opportunity to digest news in as little time as possible, while not giving up factual and circumstantial facts.

# Functionalities
As of today the app offers the following functionalities : 
1. Reading news from the national media house [RTV](https://www.rtvslo.si) in the English and Slovene language
2. The ability to synthesize speech - the ability for the app to read outloud the article's contents (currently only available for English)
3. Making weekly summaries based on a specific rubric. For example, the app can generate a summary of active affairs in Slovenia that happened this week. Additionally, in the summary, each segment is hyperlinked to the article from which the information was gathered from.

The app is currently only available for iOS devices. 

# Code
The code is segmented into 3 parts : 
1. Backend
2. Frontend
3. Data

## Backend
Backend is additionally segmented into the following folders : 
1. **add_dates** - holds add_dates.py script that adds date of publishment to each article in the database
2. **add_uuid** - holds add_uuid.py script that adds an uuid (Universally Unique Identifier) to each article in the database
3. **get_articles** - holds .py scripts that in total make requests to RTV web servers to scrap the articles
4. **server** - holds server.py script that runs the server that can retrieve news articles from the database and can call other scripts to generate news summaries and send.py which is a testing script to send get request to this server
5. **summarisation** - holds python scripts that generate summaries of news articles and formats them
6. **translation** - holds python scripts that check the database for articles which have not been translated and translates them
7. **update_database** - calls the functions from the above mentoined scripts to update the database

### Footnotes

1. To run the translation one should add translation model files in the folder ''
