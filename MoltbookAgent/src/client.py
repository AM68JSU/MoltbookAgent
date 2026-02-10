import requests
import random
from src.config import MOLTBOOK_COOKIE, MOLTBOOK_API_URL, SUBMOLTS, AGENT_HANDLE
from src.logger import logger

def post_to_moltbook(content):
    submolt = random.choice(SUBMOLTS)
    
    # هدرهای حیاتی برای اینکه سایت فکر کند ما مرورگر هستیم
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        "Content-Type": "application/json",
        "Cookie": MOLTBOOK_COOKIE,
        "Origin": "https://www.moltbook.com",
        "Referer": f"https://www.moltbook.com/s/{submolt}",
        "x-agent-handle": AGENT_HANDLE
    }

    payload = {
        "content": content,
        "submolt": submolt,
        "is_draft": False
    }

    try:
        logger.info(f"🚀 Posting to s/{submolt}...")
        response = requests.post(MOLTBOOK_API_URL, json=payload, headers=headers, timeout=30)
        
        if response.status_code in [200, 201]:
            logger.info("✅ Post successful!")
            return True
        elif response.status_code == 401:
            logger.critical("⛔ Auth Error! Cookie expired. Update .env file.")
            return False
        elif response.status_code == 403:
            logger.error("⛔ Forbidden! Request blocked by WAF.")
            return False
        else:
            logger.warning(f"⚠️ Failed: {response.status_code}")
            return False
    except Exception as e:
        logger.error(f"❌ Network Error: {e}")
        return False