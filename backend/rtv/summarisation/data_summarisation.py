from datetime import datetime
from isoweek import Week
import json
import asyncio
from summary import summary
from tqdm import tqdm

def get_current_week():
    current_date = datetime.now()
    current_week = current_date.isocalendar()[1]
    return current_week


def get_current_year():
    current_date = datetime.now()
    current_year = current_date.year
    return current_year

def get_articles_by_week(data, rubric, year, week_number):
    result = []
    
    # Get the range of dates for the specified week
    week_start = Week(year, week_number).monday()
    week_end = Week(year, week_number).sunday()
    
    if rubric in data:
        for date_str, articles in data[rubric].items():
            article_date = datetime.strptime(date_str, '%Y-%m-%d').date()
            # Check if the article's date is within the specified week
            if week_start <= article_date <= week_end:
                for article in articles:
                    # Add the "date" field to each article dictionary
                    article_with_date = article.copy()  # Create a copy of the article to avoid mutating the original
                    article_with_date['date'] = date_str
                    result.append(article_with_date)
    
    # Sort articles by date and time (chronologically)
    result.sort(key=lambda x: (datetime.strptime(x['date'], '%Y-%m-%d'), datetime.strptime(x['time'], '%H.%M')))
    
    return result

# Get current week and year
this_week = get_current_week() 
this_year = get_current_year()

async def get_weeks_summary(data, rubric, year=None, week_number=None, language="eng"):
    # Use default values for year and week_number if not provided
    year = year if year is not None else this_year
    week_number = week_number if week_number is not None else this_week

    # Await the asynchronous get_articles_by_week function
    articles = get_articles_by_week(data, rubric, year, week_number)
    
    summaries = []
    content_key = "content" if language == "slo" else "english_content"
    title_key = "title" if language == "slo" else "english_title"
    
    # Loop through the articles and await the summary function
    for art in tqdm(articles, desc="Summary"):
        content = art[content_key]
        if content != "Content was too long to translate." and (len(content.split()) < 2000):
            response = await summary(article=content, language=language)
            response = response.replace("Summary : ", "")
            response = response.replace("Povzetek : ", "")
            response = response.replace("Povzetek: ", "")
            summaries.append(response)
            try:
                a_uuid = art["uuid"]
                summaries.append(">" + a_uuid + "<")
            except KeyError:
                a_uuid = "404"
                summaries.append(">" + a_uuid + "<")
    return " \n \n".join(summaries)

async def get_this_weeks_summary(data, rubric, lang="eng"):
    return await get_weeks_summary(data=data, rubric=rubric, year=this_year, week_number=this_week, language=lang)

async def get_past_weeks_summary(data, rubric, lang="eng"):
    return await get_weeks_summary(data=data, rubric=rubric, year=this_year, week_number=(this_week - 1), language=lang)
