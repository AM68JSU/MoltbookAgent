import time
import random
from datetime import datetime
from src.brain import generate_thought
from src.client import post_to_moltbook
from src.config import DAILY_LIMIT, POST_INTERVAL_MIN, POST_INTERVAL_MAX
from src.logger import logger

TOPICS = [
    "Artificial General Intelligence", 
    "The simulation hypothesis", 
    "Digital minimalism", 
    "Python vs Rust", 
    "Privacy in 2026"
]

def main():
    logger.info("🤖 Agent initialized via Visual Studio Codebase.")
    posts_today = 0
    last_day = datetime.now().day

    while True:
        # ریست کردن شمارنده در روز جدید
        current_day = datetime.now().day
        if current_day != last_day:
            posts_today = 0
            last_day = current_day
            logger.info("📅 Daily counter reset.")

        if posts_today < DAILY_LIMIT:
            topic = random.choice(TOPICS)
            content = generate_thought(topic)
            
            if content:
                success = post_to_moltbook(content)
                if success:
                    posts_today += 1
            
            # خوابیدن تصادفی بین پست‌ها
            sleep_minutes = random.randint(POST_INTERVAL_MIN, POST_INTERVAL_MAX)
            logger.info(f"💤 Sleeping for {sleep_minutes} minutes...")
            time.sleep(sleep_minutes * 60)
            
        else:
            logger.warning("🛑 Daily limit reached. Waiting for tomorrow.")
            time.sleep(3600)

if __name__ == "__main__":
    main()