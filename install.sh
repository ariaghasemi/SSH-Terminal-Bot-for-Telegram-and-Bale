
---

## 3️⃣ فایل `install.sh`

```bash
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  SSH Terminal Bot Installer${NC}"
echo -e "${GREEN}  Telegram & Bale Messengers${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}Which messenger do you want to install?${NC}"
echo "1) Telegram"
echo "2) Bale"
echo "3) Both"
read -p "Enter your choice [1-3]: " choice

if [[ $choice -lt 1 || $choice -gt 3 ]]; then
    echo -e "${RED}Invalid choice${NC}"
    exit 1
fi

apt update
apt install -y python3 python3-pip python3-venv curl

mkdir -p /root/telegram_ssh_bot
cd /root/telegram_ssh_bot

if [[ $choice == "1" || $choice == "3" ]]; then
    echo -e "${GREEN}Installing Telegram bot...${NC}"
    
    read -p "Enter Telegram Bot Token: " TELEGRAM_TOKEN
    read -p "Enter your numeric Telegram User ID: " TELEGRAM_USER_ID
    
    mkdir -p telegram
    cat > telegram/bot.py << 'TELEGRAMCODE'
#!/usr/bin/env python3

import asyncio
import threading
import time
import logging
import re
import paramiko
from telegram import Update, KeyboardButton, ReplyKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from datetime import datetime
import os

TOKEN = "REPLACE_TOKEN"
ALLOWED_IDS = [REPLACE_USER_ID]

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

sessions = {}
user_steps = {}

def log_session(chat_id, message):
    with open("telegram_sessions.log", "a", encoding="utf-8") as f:
        f.write(f"[{datetime.now()}] [{chat_id}] {message}\n")

def clean_ansi(text):
    return re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', text)

def get_keyboard():
    keys = [
        ["🔌 Connect", "❌ Disconnect"],
        ["⛔ Ctrl+C", "🔚 Ctrl+D"],
        ["💾 Ctrl+X", "💾 Ctrl+X+Y"],
        ["🚫 Ctrl+X+N", "🧹 Clear File"],
        ["📤 Upload & Paste", "🔁 Last 50 Lines"],
        ["🔁 Last 100 Lines", "⏎ Enter"],
        ["📋 Help", "🔄 Reconnect"]
    ]
    return ReplyKeyboardMarkup(keys, resize_keyboard=True)

async def start(update, context):
    if update.effective_chat.id not in ALLOWED_IDS:
        await update.message.reply_text("Access denied")
        return
    await update.message.reply_text(
        "🤖 SSH Terminal Bot\nUse buttons below to connect",
        reply_markup=get_keyboard()
    )

async def handle_text(update, context):
    chat_id = update.effective_chat.id
    text = update.message.text

    if chat_id not in ALLOWED_IDS:
        return

    if text == "🔌 Connect":
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text("Enter server IP or hostname:", reply_markup=get_keyboard())
    elif text == "❌ Disconnect":
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            await update.message.reply_text("SSH session closed", reply_markup=get_keyboard())
    elif text == "⛔ Ctrl+C" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x03')
        await update.message.reply_text("Ctrl+C sent", reply_markup=get_keyboard())
    elif text == "🔚 Ctrl+D" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x04')
        await update.message.reply_text("Ctrl+D sent", reply_markup=get_keyboard())
    elif text == "💾 Ctrl+X" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18')
        await update.message.reply_text("Ctrl+X sent", reply_markup=get_keyboard())
    elif text == "💾 Ctrl+X+Y" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18Y\n')
        await update.message.reply_text("Ctrl+X+Y sent (save & exit)", reply_markup=get_keyboard())
    elif text == "🚫 Ctrl+X+N" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18N\n')
        await update.message.reply_text("Ctrl+X+N sent (cancel)", reply_markup=get_keyboard())
    elif text == "🧹 Clear File" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[chat_id]["channel"].send(b'\x7f')
        await update.message.reply_text("File content cleared", reply_markup=get_keyboard())
    elif text == "📤 Upload & Paste":
        context.user_data['awaiting_upload'] = True
        await update.message.reply_text("Send a .txt file to paste in terminal", reply_markup=get_keyboard())
    elif text == "🔁 Last 50 Lines" and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -50\n")
        await update.message.reply_text("Sending last 50 lines...", reply_markup=get_keyboard())
    elif text == "🔁 Last 100 Lines" and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -100\n")
        await update.message.reply_text("Sending last 100 lines...", reply_markup=get_keyboard())
    elif text == "⏎ Enter" and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\n')
        await update.message.reply_text("Enter sent", reply_markup=get_keyboard())
    elif text == "📋 Help":
        await update.message.reply_text(
            "Commands:\n"
            "Connect - SSH connection\n"
            "Ctrl+C - Interrupt\n"
            "Ctrl+D - Exit shell\n"
            "Ctrl+X - Exit editors\n"
            "Upload & Paste - Send text file\n"
            "Last Lines - Show history",
            reply_markup=get_keyboard()
        )
    elif text == "🔄 Reconnect":
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            time.sleep(1)
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text("Reconnecting...\nEnter server IP:", reply_markup=get_keyboard())
    elif chat_id in user_steps:
        step = user_steps[chat_id].get("step")
        if step == "host":
            user_steps[chat_id]["host"] = text
            user_steps[chat_id]["step"] = "port"
            await update.message.reply_text("Enter SSH port (default 22):", reply_markup=get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[chat_id]["port"] = port
            user_steps[chat_id]["step"] = "username"
            await update.message.reply_text("Enter username:", reply_markup=get_keyboard())
        elif step == "username":
            user_steps[chat_id]["username"] = text
            user_steps[chat_id]["step"] = "password"
            await update.message.reply_text("Enter password:", reply_markup=get_keyboard())
        elif step == "password":
            await do_ssh_connect(update, context, chat_id, user_steps[chat_id])
            del user_steps[chat_id]
    elif chat_id in sessions:
        sessions[chat_id]["channel"].send(text + "\n")
        log_session(chat_id, f"CMD: {text}")
        await update.message.reply_text(f"Command sent: {text}", reply_markup=get_keyboard())
    else:
        await update.message.reply_text("Press Connect button first", reply_markup=get_keyboard())

async def do_ssh_connect(update, context, chat_id, data):
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=data["host"],
            port=data["port"],
            username=data["username"],
            password=data["password"],
            timeout=10
        )
        channel = client.invoke_shell(term='xterm', width=120, height=40)
        channel.settimeout(0.1)

        sessions[chat_id] = {"ssh": client, "channel": channel}

        def reader():
            while chat_id in sessions:
                try:
                    if channel.recv_ready():
                        output = channel.recv(4096).decode('utf-8', errors='ignore')
                        if output:
                            asyncio.run_coroutine_threadsafe(
                                update.message.reply_text(clean_ansi(output), reply_markup=get_keyboard()),
                                context.application.loop
                            )
                except:
                    break
                time.sleep(0.1)

        threading.Thread(target=reader, daemon=True).start()
        await update.message.reply_text(f"Connected to {data['username']}@{data['host']}", reply_markup=get_keyboard())
        channel.send("\n")
        log_session(chat_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        await update.message.reply_text(f"Connection failed: {str(e)}", reply_markup=get_keyboard())

async def handle_document(update, context):
    chat_id = update.effective_chat.id
    if context.user_data.get('awaiting_upload') and chat_id in sessions:
        doc = update.message.document
        if doc.file_name.endswith('.txt'):
            file = await context.bot.get_file(doc.file_id)
            downloaded = await file.download_to_drive()
            with open(downloaded.name, 'r', encoding='utf-8') as f:
                content = f.read()
            channel = sessions[chat_id]["channel"]
            for char in content:
                channel.send(char)
                await asyncio.sleep(0.002)
            await update.message.reply_text("File content pasted in terminal", reply_markup=get_keyboard())
            context.user_data['awaiting_upload'] = False
        else:
            await update.message.reply_text("Only .txt files are accepted", reply_markup=get_keyboard())

def main():
    app = Application.builder().token(TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text))
    app.add_handler(MessageHandler(filters.Document.ALL, handle_document))
    logger.info("Telegram bot started")
    app.run_polling()

if __name__ == "__main__":
    main()
TELEGRAMCODE

    sed -i "s/REPLACE_TOKEN/$TELEGRAM_TOKEN/" telegram/bot.py
    sed -i "s/REPLACE_USER_ID/$TELEGRAM_USER_ID/" telegram/bot.py

    cat > telegram/requirements.txt << 'TELREQ'
python-telegram-bot==20.7
paramiko==3.4.0
TELREQ

    cd telegram
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..

    cat > /etc/systemd/system/telegram-ssh-bot.service << 'SERVICE'
[Unit]
Description=Telegram SSH Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/telegram_ssh_bot/telegram
ExecStart=/root/telegram_ssh_bot/telegram/venv/bin/python /root/telegram_ssh_bot/telegram/bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

    systemctl daemon-reload
    systemctl enable telegram-ssh-bot
    systemctl start telegram-ssh-bot
    echo -e "${GREEN}Telegram bot installed successfully${NC}"
fi

if [[ $choice == "2" || $choice == "3" ]]; then
    echo -e "${GREEN}Installing Bale bot...${NC}"
    
    read -p "Enter Bale Bot Token: " BALE_TOKEN
    read -p "Enter your numeric Bale User ID: " BALE_USER_ID
    
    mkdir -p bale
    cat > bale/bot.py << 'BALECODE'
#!/usr/bin/env python3

import threading
import time
import logging
import re
import paramiko
import json
import requests
from datetime import datetime

TOKEN = "REPLACE_TOKEN"
API_URL = f"https://tapi.bale.ai/bot{TOKEN}/"
ALLOWED_IDS = [REPLACE_USER_ID]

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

sessions = {}
user_steps = {}
last_update_id = 0

def log_session(user_id, message):
    with open("bale_sessions.log", "a", encoding="utf-8") as f:
        f.write(f"[{datetime.now()}] [{user_id}] {message}\n")

def clean_ansi(text):
    return re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', text)

def get_keyboard():
    return {
        "keyboard": [
            ["🔌 Connect", "❌ Disconnect"],
            ["⛔ Ctrl+C", "🔚 Ctrl+D"],
            ["💾 Ctrl+X", "💾 Ctrl+X+Y"],
            ["🚫 Ctrl+X+N", "🧹 Clear File"],
            ["📤 Upload & Paste", "🔁 Last 50 Lines"],
            ["🔁 Last 100 Lines", "⏎ Enter"],
            ["📋 Help", "🔄 Reconnect"]
        ],
        "resize_keyboard": True
    }

def send_message(chat_id, text, keyboard=None):
    payload = {"chat_id": chat_id, "text": text, "parse_mode": "Markdown"}
    if keyboard:
        payload["reply_markup"] = json.dumps(keyboard)
    try:
        requests.post(API_URL + "sendMessage", json=payload, timeout=5)
    except Exception as e:
        logger.error(f"Send error: {e}")

def do_ssh_connect(chat_id, user_id, data):
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=data["host"],
            port=data["port"],
            username=data["username"],
            password=data["password"],
            timeout=10
        )
        channel = client.invoke_shell(term='xterm', width=120, height=40)
        channel.settimeout(0.1)

        sessions[user_id] = {"ssh": client, "channel": channel, "chat_id": chat_id}

        def reader():
            while user_id in sessions:
                try:
                    if channel.recv_ready():
                        output = channel.recv(4096).decode('utf-8', errors='ignore')
                        if output:
                            send_message(chat_id, clean_ansi(output), get_keyboard())
                except:
                    break
                time.sleep(0.1)

        threading.Thread(target=reader, daemon=True).start()
        send_message(chat_id, f"Connected to {data['username']}@{data['host']}", get_keyboard())
        channel.send("\n")
        log_session(user_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        send_message(chat_id, f"Connection failed: {str(e)}", get_keyboard())

def process_message(chat_id, user_id, text):
    if text == "🔌 Connect":
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, "Enter server IP or hostname:", get_keyboard())
    elif text == "❌ Disconnect":
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            send_message(chat_id, "SSH session closed", get_keyboard())
    elif text == "⛔ Ctrl+C" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x03')
        send_message(chat_id, "Ctrl+C sent", get_keyboard())
    elif text == "🔚 Ctrl+D" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x04')
        send_message(chat_id, "Ctrl+D sent", get_keyboard())
    elif text == "💾 Ctrl+X" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18')
        send_message(chat_id, "Ctrl+X sent", get_keyboard())
    elif text == "💾 Ctrl+X+Y" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18Y\n')
        send_message(chat_id, "Ctrl+X+Y sent (save & exit)", get_keyboard())
    elif text == "🚫 Ctrl+X+N" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18N\n')
        send_message(chat_id, "Ctrl+X+N sent (cancel)", get_keyboard())
    elif text == "🧹 Clear File" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[user_id]["channel"].send(b'\x7f')
        send_message(chat_id, "File content cleared", get_keyboard())
    elif text == "📤 Upload & Paste":
        user_steps[user_id] = {"step": "awaiting_upload"}
        send_message(chat_id, "Send a .txt file to paste in terminal", get_keyboard())
    elif text == "🔁 Last 50 Lines" and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -50\n")
        send_message(chat_id, "Sending last 50 lines...", get_keyboard())
    elif text == "🔁 Last 100 Lines" and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -100\n")
        send_message(chat_id, "Sending last 100 lines...", get_keyboard())
    elif text == "⏎ Enter" and user_id in sessions:
        sessions[user_id]["channel"].send(b'\n')
        send_message(chat_id, "Enter sent", get_keyboard())
    elif text == "📋 Help":
        send_message(chat_id, 
            "Commands:\nConnect - SSH connection\nCtrl+C - Interrupt\nCtrl+D - Exit shell\nUpload & Paste - Send text file\nLast Lines - Show history",
            get_keyboard())
    elif text == "🔄 Reconnect":
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            time.sleep(1)
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, "Reconnecting...\nEnter server IP:", get_keyboard())
    elif text == "/start":
        send_message(chat_id, "🤖 SSH Terminal Bot for Bale\nUse buttons below to connect", get_keyboard())
    elif user_id in user_steps:
        step = user_steps[user_id].get("step")
        if step == "host":
            user_steps[user_id]["host"] = text
            user_steps[user_id]["step"] = "port"
            send_message(chat_id, "Enter SSH port (default 22):", get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[user_id]["port"] = port
            user_steps[user_id]["step"] = "username"
            send_message(chat_id, "Enter username:", get_keyboard())
        elif step == "username":
            user_steps[user_id]["username"] = text
            user_steps[user_id]["step"] = "password"
            send_message(chat_id, "Enter password:", get_keyboard())
        elif step == "password":
            do_ssh_connect(chat_id, user_id, user_steps[user_id])
            del user_steps[user_id]
    elif user_id in sessions:
        sessions[user_id]["channel"].send(text + "\n")
        log_session(user_id, f"CMD: {text}")
        send_message(chat_id, f"Command sent: {text}", get_keyboard())
    else:
        send_message(chat_id, "Press Connect button first", get_keyboard())

def process_document(chat_id, user_id, file_id):
    if user_id in user_steps and user_steps[user_id].get("step") == "awaiting_upload":
        response = requests.post(API_URL + "getFile", json={"file_id": file_id})
        if response.status_code == 200:
            file_path = response.json().get('result', {}).get('file_path')
            if file_path:
                file_url = f"https://tapi.bale.ai/file/bot{TOKEN}/{file_path}"
                content = requests.get(file_url).text
                if user_id in sessions:
                    channel = sessions[user_id]["channel"]
                    for char in content:
                        channel.send(char)
                        time.sleep(0.002)
                    send_message(chat_id, "File content pasted in terminal", get_keyboard())
                else:
                    send_message(chat_id, "Connect to SSH first", get_keyboard())
        del user_steps[user_id]
    else:
        send_message(chat_id, "Press Upload & Paste button first", get_keyboard())

def get_updates():
    global last_update_id
    try:
        response = requests.get(API_URL + "getUpdates", params={"offset": last_update_id + 1, "timeout": 30})
        if response.status_code == 200:
            updates = response.json().get('result', [])
            for update in updates:
                last_update_id = update.get('update_id', last_update_id)
                if 'message' in update:
                    msg = update['message']
                    chat_id = msg['chat']['id']
                    user_id = msg['from']['id']
                    if user_id not in ALLOWED_IDS:
                        send_message(chat_id, "Access denied")
                        continue
                    if 'document' in msg:
                        process_document(chat_id, user_id, msg['document']['file_id'])
                    elif 'text' in msg:
                        process_message(chat_id, user_id, msg['text'])
    except Exception as e:
        logger.error(f"Updates error: {e}")

def main():
    logger.info("Bale bot started")
    while True:
        try:
            get_updates()
        except Exception as e:
            logger.error(f"Main loop error: {e}")
            time.sleep(5)

if __name__ == "__main__":
    main()
BALECODE

    sed -i "s/REPLACE_TOKEN/$BALE_TOKEN/" bale/bot.py
    sed -i "s/REPLACE_USER_ID/$BALE_USER_ID/" bale/bot.py

    cat > bale/requirements.txt << 'BALEREQ'
paramiko==3.4.0
requests==2.33.1
BALEREQ

    cd bale
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    cd ..

    cat > /etc/systemd/system/bale-ssh-bot.service << 'SERVICE'
[Unit]
Description=Bale SSH Bot
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/telegram_ssh_bot/bale
ExecStart=/root/telegram_ssh_bot/bale/venv/bin/python /root/telegram_ssh_bot/bale/bot.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
SERVICE

    systemctl daemon-reload
    systemctl enable bale-ssh-bot
    systemctl start bale-ssh-bot
    echo -e "${GREEN}Bale bot installed successfully${NC}"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Installation completed!${NC}"
echo -e "${GREEN}Check status with: systemctl status telegram-ssh-bot${NC}"
echo -e "${GREEN}                 or: systemctl status bale-ssh-bot${NC}"
