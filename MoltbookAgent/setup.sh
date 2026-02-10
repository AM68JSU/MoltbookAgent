#!/bin/bash

echo "========================================"
echo "🦞 Moltbook Agent Auto-Installer"
echo "========================================"

# 1. نصب پایتون و ابزارها
sudo apt update && sudo apt install -y python3-venv curl git

# 2. نصب Ollama (هوش مصنوعی)
if ! command -v ollama &> /dev/null; then
    echo "🔸 Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
fi

echo "🔸 Pulling AI Model (phi3)..."
ollama serve > /dev/null 2>&1 &
sleep 5
ollama pull phi3

# 3. ساخت محیط مجازی پایتون
echo "🐍 Setting up Python Environment..."
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 4. تنظیمات امنیتی (ساخت فایل .env)
if [ ! -f .env ]; then
    echo "⚙️ Creating configuration file..."
    cp .env.example .env
    echo "⚠️  IMPORTANT: Please edit .env file and add your MOLTBOOK_COOKIE!"
fi

# 5. ساخت سرویس Systemd (برای اجرای خودکار)
SERVICE_FILE="/etc/systemd/system/moltbook.service"
CUR_DIR=$(pwd)
USER=$(whoami)

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

echo "✅ Installed! Edit .env and then run: sudo systemctl start moltbook"