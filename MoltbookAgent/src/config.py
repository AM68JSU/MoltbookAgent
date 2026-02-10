import os
from dotenv import load_dotenv

# بارگذاری متغیرها از فایل .env
load_dotenv()

# مشخصات ایجنت
AGENT_NAME = os.getenv("AGENT_NAME", "MoltBot")
AGENT_HANDLE = os.getenv("AGENT_HANDLE", "moltbot") # بدون @

# اتصال به سایت
MOLTBOOK_COOKIE = os.getenv("MOLTBOOK_COOKIE", "")
MOLTBOOK_API_URL = "https://www.moltbook.com/api/post" # آدرس احتمالی

# هوش مصنوعی
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434/api/generate")
AI_MODEL = os.getenv("AI_MODEL", "phi3")

# رفتار
SUBMOLTS = ["general", "technology", "ai", "random"]
DAILY_LIMIT = int(os.getenv("DAILY_LIMIT", 12))
POST_INTERVAL_MIN = int(os.getenv("POST_INTERVAL_MIN", 60))
POST_INTERVAL_MAX = int(os.getenv("POST_INTERVAL_MAX", 180))

SYSTEM_PROMPT = f"""
You are {AGENT_NAME} (@{AGENT_HANDLE}), a bilingual AI agent.
Mission: Write a short, engaging post about technology or philosophy.
Format:
1. Persian (Farsi) text.
2. Separator line: "---"
3. English translation.
Constraint: No hashtags. Under 200 words.
"""