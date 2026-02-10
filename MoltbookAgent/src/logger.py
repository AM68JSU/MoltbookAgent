import logging
import sys

def setup_logger():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - [%(levelname)s] - %(message)s',
        handlers=[
            logging.FileHandler("agent.log"),
            logging.StreamHandler(sys.stdout)
        ]
    )
    return logging.getLogger("MoltAgent")

logger = setup_logger()