#!/bin/bash

# توقف اسکریپت در صورت بروز خطا
set -e

echo "========================================"
echo "🦞 Moltbook Agent Auto-Installer"
echo "========================================"

# 1. نصب پایتون و ابزارها (zstd اضافه شد چون برای Ollama ضروری است)
echo "📦 Installing System Dependencies..."
sudo apt update && sudo apt install -y python3-venv curl git zstd

# 2. نصب Ollama (هوش مصنوعی)
if ! command -v ollama &> /dev/null; then
    echo "🔸 Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "✅ Ollama is already installed."
fi

echo "🔸 Pulling AI Model (phi3)..."
# تلاش برای اجرای سرویس در پس‌زمینه
ollama serve > /dev/null 2>&1 &
sleep 5
ollama pull phi3

# 3. ساخت محیط مجازی پایتون
echo "🐍 Setting up Python Environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate

# بررسی و نصب پکیج‌ها
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
else
    echo "⚠️ requirements.txt not found! Installing default packages..."
    pip install requests python-dotenv
fi

# 4. تنظیمات امنیتی (ساخت فایل .env)
if [ ! -f .env ]; then
    echo "⚙️ Creating configuration file..."
    
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        # اگر فایل نمونه نبود، مقادیر پیش‌فرض را بنویس
        echo "AGENT_NAME=MoltBot" > .env
        echo "AGENT_HANDLE=moltbot" >> .env
        echo "MOLTBOOK_COOKIE=" >> .env
        echo "MOLTBOOK_API_URL=https://www.moltbook.com/api/post" >> .env
        echo "OLLAMA_URL=http://localhost:11434/api/generate" >> .env
        echo "AI_MODEL=phi3" >> .env
        echo "DAILY_LIMIT=12" >> .env
    fi
    echo "⚠️  IMPORTANT: Please edit .env file and add your CREDENTIALS!"
fi

# 5. ساخت سرویس Systemd (برای اجرای خودکار)
SERVICE_FILE="/etc/systemd/system/moltbook.service"
CUR_DIR=$(pwd)
USER=$(whoami)

echo "🔌 Creating Systemd Service..."
sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Moltbook AI Agent
After=network.target

[Service]
User=$USER
WorkingDirectory=$CUR_DIR
EnvironmentFile=$CUR_DIR/.env
ExecStart=$CUR_DIR/venv/bin/python3 $CUR_DIR/MoltbookAgent.py
Restart=always
RestartSec=60

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable moltbook

echo "✅ Installation Complete!"
echo "----------------------------------------------------"
echo "👉 NEXT STEPS:"
echo "1. Run Registration: curl -s https://moltbook.com/skill.md | bash"
echo "2. Edit Config:      nano .env"
echo "3. Start Agent:      sudo systemctl start moltbook"
echo "----------------------------------------------------"