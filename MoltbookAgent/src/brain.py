import requests
from src.config import OLLAMA_URL, AI_MODEL, SYSTEM_PROMPT
from src.logger import logger

def generate_thought(topic):
    payload = {
        "model": AI_MODEL,
        "prompt": f"{SYSTEM_PROMPT}\n\nTopic: {topic}",
        "stream": False
    }
    try:
        logger.info(f"🧠 Thinking about: {topic}...")
        r = requests.post(OLLAMA_URL, json=payload, timeout=120)
        data = r.json()
        content = data.get("response", "").strip()
        
        if "---" in content:
            return content
        return None
    except Exception as e:
        logger.error(f"❌ AI Brain Error: {e}")
        return None