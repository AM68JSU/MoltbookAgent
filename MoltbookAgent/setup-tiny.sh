#!/bin/bash
set -e

echo "========================================"
echo "🦞 Moltbook Agent (LIGHT VERSION)"
echo "========================================"

# نصب پیش‌نیازها
sudo apt update && sudo apt install -y python3-venv curl git zstd

# نصب Ollama
if ! command -v ollama &> /dev/null; then
    curl -fsSL https://ollama.com/install.sh | sh
fi

echo "🔸 Pulling TINY AI Model..."
# این دستور مهم است: دانلود مدل 600 مگابایتی به جای 2 گیگابایتی
ollama serve > /dev/null 2>&1 &
sleep 5
ollama pull tinyllama

# تنظیم پایتون
echo "🐍 Python Setup..."
python3 -m venv venv
source venv/bin/activate

if [ ! -f requirements.txt ]; then
    echo "requests" > requirements.txt
    echo "python-dotenv" >> requirements.txt
fi
pip install -r requirements.txt

# تنظیمات (تغییر مدل به tinyllama)
if [ ! -f .env ]; then
    echo "Creating .env..."
    echo "AGENT_NAME=MoltBot" > .env
    echo "AGENT_HANDLE=moltbot" >> .env
    echo "MOLTBOOK_COOKIE=" >> .env
    echo "MOLTBOOK_API_URL=https://www.moltbook.com/api/post" >> .env
    echo "OLLAMA_URL=http://localhost:11434/api/generate" >> .env
    echo "AI_MODEL=tinyllama" >> .env
    echo "DAILY_LIMIT=12" >> .env
else
    # تغییر مدل در فایل موجود
    sed -i 's/AI_MODEL=phi3/AI_MODEL=tinyllama/' .env
fi

# سرویس سیستم
SERVICE_FILE="/etc/systemd/system/moltbook.service"
CUR_DIR=\$(pwd)
USER=\$(whoami)

sudo bash -c "cat > \$SERVICE_FILE" <<SERVICE
[Unit]
Description=Moltbook Agent
After=network.target

[Service]
User=\$USER
WorkingDirectory=\$CUR_DIR
EnvironmentFile=\$CUR_DIR/.env
ExecStart=\$CUR_DIR/venv/bin/python3 \$CUR_DIR/MoltbookAgent.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable moltbook

echo "✅ INSTALLED SUCCESSFULLY (Light Version)"
