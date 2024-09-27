from groq import Groq
import json
import asyncio
import os 


api_key = os.getenv("GROQ_API_KEY")
if not api_key:
    print("Please set your groq api key...")

# Initialize the Groq client
client = Groq(api_key=api_key)

async def llama(prompt, sys_prompt="", temperature=0.5, max_tokens=1024):
    # Use asyncio to run the synchronous method in a thread to avoid blocking
    loop = asyncio.get_event_loop()
    chat_completion = await loop.run_in_executor(
        None,  # Use default executor
        lambda: client.chat.completions.create(
            messages=[
                {"role": "system", "content": sys_prompt},
                {"role": "user", "content": prompt},
            ],
            model="llama3-8b-8192",
            temperature=temperature,
            max_tokens=max_tokens,
            top_p=1,
            stop=None,
            stream=False,
        )
    )

    # Return the completion from the LLM response
    return chat_completion.choices[0].message.content

# Read the system prompt from the file
sys_prompt_path = "backend/rtv/summarisation/system_prompt.txt"
sys_prompt_path_slo = "backend/rtv/summarisation/system_prompt_slo.txt"


with open(sys_prompt_path, "r", encoding="utf-8") as file:
    system_prompt_eng = file.read()

with open(sys_prompt_path_slo, "r", encoding="utf-8") as file:
    system_prompt_slo = file.read()


# Asynchronous summary function
async def summary(article, language):
    if language == "eng":
        system_prompt = system_prompt_eng
    else:
        system_prompt = system_prompt_slo
    return await llama(prompt=article, sys_prompt=system_prompt)



