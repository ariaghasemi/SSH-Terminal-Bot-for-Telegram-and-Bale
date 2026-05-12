#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

echo -e "${YELLOW}Choose bot language:${NC}"
echo "1) Persian (فارسی)"
echo "2) English"
read -p "Enter your choice [1-2]: " lang_choice

if [[ $lang_choice == "1" ]]; then
    LANG="fa"
    CONNECT_BTN="🔌 اتصال"
    DISCONNECT_BTN="❌ قطع اتصال"
    CTRL_C_BTN="⛔ Ctrl+C"
    CTRL_D_BTN="🔚 Ctrl+D"
    CTRL_X_BTN="💾 Ctrl+X"
    CTRL_X_Y_BTN="💾 Ctrl+X+Y"
    CTRL_X_N_BTN="🚫 Ctrl+X+N"
    CLEAR_BTN="🧹 پاک کردن فایل"
    UPLOAD_BTN="📤 آپلود و پیست"
    LAST_50_BTN="🔁 50 خط آخر"
    LAST_100_BTN="🔁 100 خط آخر"
    ENTER_BTN="⏎ Enter"
    HELP_BTN="📋 راهنما"
    RECONNECT_BTN="🔄 اتصال مجدد"
    DEV_BTN="👨‍💻 توسعه دهنده"
    
    START_MSG="🤖 ربات ترمینال SSH\nاز دکمه‌های زیر برای اتصال استفاده کن"
    CONNECT_PROMPT="آدرس IP یا هاست سرور را وارد کن:"
    PORT_PROMPT="پورت SSH (پیش‌فرض 22):"
    USERNAME_PROMPT="نام کاربری:"
    PASSWORD_PROMPT="رمز عبور:"
    CONNECTED_MSG="متصل شدی به"
    CONNECTION_FAILED="اتصال ناموفق:"
    SESSION_CLOSED="جلسه SSH بسته شد"
    NO_SESSION="هیچ جلسه فعالی نیست"
    CTRL_SENT="ارسال شد"
    SAVE_EXIT="ذخیره و خروج"
    CANCEL="لغو تغییرات"
    CLEAR_MSG="محتوای فایل پاک شد"
    UPLOAD_MSG="فایل txt را ارسال کن تا در ترمینال پیست شود"
    PASTED_MSG="محتوای فایل در ترمینال پیست شد"
    SENDING_LINES="در حال ارسال خطوط"
    ENTER_SENT="Enter ارسال شد"
    RECONNECT_MSG="در حال اتصال مجدد..."
    ACCESS_DENIED="دسترسی غیرمجاز"
    PRESS_CONNECT="ابتدا دکمه اتصال را بزن"
    ONLY_TXT="فقط فایل txt قبول می‌شود"
    CONNECT_FIRST="ابتدا به سرور متصل شو"
    HELP_TEXT="راهنما:\nاتصال - اتصال به SSH\nCtrl+C - قطع فرمان\nCtrl+D - خروج از شل\nآپلود و پیست - ارسال فایل متنی\nخطوط آخر - نمایش تاریخچه"
    
    DEV_TEXT="👨‍💻 توسعه دهنده:\n\n📱 تلگرام: @Aria_qi\n💚 بله: @aria_qi\n🐙 گیت‌هاب: github.com/ariaghasemi"
else
    LANG="en"
    CONNECT_BTN="🔌 Connect"
    DISCONNECT_BTN="❌ Disconnect"
    CTRL_C_BTN="⛔ Ctrl+C"
    CTRL_D_BTN="🔚 Ctrl+D"
    CTRL_X_BTN="💾 Ctrl+X"
    CTRL_X_Y_BTN="💾 Ctrl+X+Y"
    CTRL_X_N_BTN="🚫 Ctrl+X+N"
    CLEAR_BTN="🧹 Clear File"
    UPLOAD_BTN="📤 Upload & Paste"
    LAST_50_BTN="🔁 Last 50 Lines"
    LAST_100_BTN="🔁 Last 100 Lines"
    ENTER_BTN="⏎ Enter"
    HELP_BTN="📋 Help"
    RECONNECT_BTN="🔄 Reconnect"
    DEV_BTN="👨‍💻 Developer"
    
    START_MSG="🤖 SSH Terminal Bot\nUse buttons below to connect"
    CONNECT_PROMPT="Enter server IP or hostname:"
    PORT_PROMPT="Enter SSH port (default 22):"
    USERNAME_PROMPT="Enter username:"
    PASSWORD_PROMPT="Enter password:"
    CONNECTED_MSG="Connected to"
    CONNECTION_FAILED="Connection failed:"
    SESSION_CLOSED="SSH session closed"
    NO_SESSION="No active session"
    CTRL_SENT="sent"
    SAVE_EXIT="save & exit"
    CANCEL="cancel"
    CLEAR_MSG="File content cleared"
    UPLOAD_MSG="Send a .txt file to paste in terminal"
    PASTED_MSG="File content pasted in terminal"
    SENDING_LINES="Sending lines"
    ENTER_SENT="Enter sent"
    RECONNECT_MSG="Reconnecting..."
    ACCESS_DENIED="Access denied"
    PRESS_CONNECT="Press Connect button first"
    ONLY_TXT="Only .txt files are accepted"
    CONNECT_FIRST="Connect to SSH first"
    HELP_TEXT="Commands:\nConnect - SSH connection\nCtrl+C - Interrupt\nCtrl+D - Exit shell\nUpload & Paste - Send text file\nLast Lines - Show history"
    
    DEV_TEXT="👨‍💻 Developer:\n\n📱 Telegram: @Aria_qi\n💚 Bale: @aria_qi\n🐙 GitHub: github.com/ariaghasemi"
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
    cat > telegram/bot.py << TELEGRAMCODE
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

TOKEN = "$TELEGRAM_TOKEN"
ALLOWED_IDS = [$TELEGRAM_USER_ID]

# Language strings
CONNECT_BTN = "$CONNECT_BTN"
DISCONNECT_BTN = "$DISCONNECT_BTN"
CTRL_C_BTN = "$CTRL_C_BTN"
CTRL_D_BTN = "$CTRL_D_BTN"
CTRL_X_BTN = "$CTRL_X_BTN"
CTRL_X_Y_BTN = "$CTRL_X_Y_BTN"
CTRL_X_N_BTN = "$CTRL_X_N_BTN"
CLEAR_BTN = "$CLEAR_BTN"
UPLOAD_BTN = "$UPLOAD_BTN"
LAST_50_BTN = "$LAST_50_BTN"
LAST_100_BTN = "$LAST_100_BTN"
ENTER_BTN = "$ENTER_BTN"
HELP_BTN = "$HELP_BTN"
RECONNECT_BTN = "$RECONNECT_BTN"
DEV_BTN = "$DEV_BTN"

START_MSG = "$START_MSG"
CONNECT_PROMPT = "$CONNECT_PROMPT"
PORT_PROMPT = "$PORT_PROMPT"
USERNAME_PROMPT = "$USERNAME_PROMPT"
PASSWORD_PROMPT = "$PASSWORD_PROMPT"
CONNECTED_MSG = "$CONNECTED_MSG"
CONNECTION_FAILED = "$CONNECTION_FAILED"
SESSION_CLOSED = "$SESSION_CLOSED"
NO_SESSION = "$NO_SESSION"
CTRL_SENT = "$CTRL_SENT"
SAVE_EXIT = "$SAVE_EXIT"
CANCEL = "$CANCEL"
CLEAR_MSG = "$CLEAR_MSG"
UPLOAD_MSG = "$UPLOAD_MSG"
PASTED_MSG = "$PASTED_MSG"
SENDING_LINES = "$SENDING_LINES"
ENTER_SENT = "$ENTER_SENT"
RECONNECT_MSG = "$RECONNECT_MSG"
ACCESS_DENIED = "$ACCESS_DENIED"
PRESS_CONNECT = "$PRESS_CONNECT"
ONLY_TXT = "$ONLY_TXT"
CONNECT_FIRST = "$CONNECT_FIRST"
HELP_TEXT = "$HELP_TEXT"
DEV_TEXT = "$DEV_TEXT"

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
        [CONNECT_BTN, DISCONNECT_BTN],
        [CTRL_C_BTN, CTRL_D_BTN],
        [CTRL_X_BTN, CTRL_X_Y_BTN],
        [CTRL_X_N_BTN, CLEAR_BTN],
        [UPLOAD_BTN, LAST_50_BTN],
        [LAST_100_BTN, ENTER_BTN],
        [HELP_BTN, RECONNECT_BTN],
        [DEV_BTN]
    ]
    return ReplyKeyboardMarkup(keys, resize_keyboard=True)

async def start(update, context):
    if update.effective_chat.id not in ALLOWED_IDS:
        await update.message.reply_text(ACCESS_DENIED)
        return
    await update.message.reply_text(START_MSG, reply_markup=get_keyboard())

async def handle_text(update, context):
    chat_id = update.effective_chat.id
    text = update.message.text

    if chat_id not in ALLOWED_IDS:
        return

    if text == CONNECT_BTN:
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text(CONNECT_PROMPT, reply_markup=get_keyboard())
    elif text == DISCONNECT_BTN:
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            await update.message.reply_text(SESSION_CLOSED, reply_markup=get_keyboard())
        else:
            await update.message.reply_text(NO_SESSION, reply_markup=get_keyboard())
    elif text == CTRL_C_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x03')
        await update.message.reply_text(f"Ctrl+C {CTRL_SENT}", reply_markup=get_keyboard())
    elif text == CTRL_D_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x04')
        await update.message.reply_text(f"Ctrl+D {CTRL_SENT}", reply_markup=get_keyboard())
    elif text == CTRL_X_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18')
        await update.message.reply_text(f"Ctrl+X {CTRL_SENT}", reply_markup=get_keyboard())
    elif text == CTRL_X_Y_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18Y\n')
        await update.message.reply_text(f"Ctrl+X+Y {CTRL_SENT} ({SAVE_EXIT})", reply_markup=get_keyboard())
    elif text == CTRL_X_N_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18N\n')
        await update.message.reply_text(f"Ctrl+X+N {CTRL_SENT} ({CANCEL})", reply_markup=get_keyboard())
    elif text == CLEAR_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[chat_id]["channel"].send(b'\x7f')
        await update.message.reply_text(CLEAR_MSG, reply_markup=get_keyboard())
    elif text == UPLOAD_BTN:
        context.user_data['awaiting_upload'] = True
        await update.message.reply_text(UPLOAD_MSG, reply_markup=get_keyboard())
    elif text == LAST_50_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -50\n")
        await update.message.reply_text(f"{SENDING_LINES} 50...", reply_markup=get_keyboard())
    elif text == LAST_100_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -100\n")
        await update.message.reply_text(f"{SENDING_LINES} 100...", reply_markup=get_keyboard())
    elif text == ENTER_BTN and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\n')
        await update.message.reply_text(ENTER_SENT, reply_markup=get_keyboard())
    elif text == HELP_BTN:
        await update.message.reply_text(HELP_TEXT, reply_markup=get_keyboard())
    elif text == RECONNECT_BTN:
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            time.sleep(1)
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text(RECONNECT_MSG, reply_markup=get_keyboard())
    elif text == DEV_BTN:
        await update.message.reply_text(DEV_TEXT, reply_markup=get_keyboard())
    elif chat_id in user_steps:
        step = user_steps[chat_id].get("step")
        if step == "host":
            user_steps[chat_id]["host"] = text
            user_steps[chat_id]["step"] = "port"
            await update.message.reply_text(PORT_PROMPT, reply_markup=get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[chat_id]["port"] = port
            user_steps[chat_id]["step"] = "username"
            await update.message.reply_text(USERNAME_PROMPT, reply_markup=get_keyboard())
        elif step == "username":
            user_steps[chat_id]["username"] = text
            user_steps[chat_id]["step"] = "password"
            await update.message.reply_text(PASSWORD_PROMPT, reply_markup=get_keyboard())
        elif step == "password":
            password = text
            if text.startswith('@') or "'" in text or '"' in text:
                password = f"'{text}'"
            user_steps[chat_id]["password"] = password
            await do_ssh_connect(update, context, chat_id, user_steps[chat_id])
            del user_steps[chat_id]
    elif chat_id in sessions:
        sessions[chat_id]["channel"].send(text + "\n")
        log_session(chat_id, f"CMD: {text}")
        await update.message.reply_text(f"Command sent: {text}", reply_markup=get_keyboard())
    else:
        await update.message.reply_text(PRESS_CONNECT, reply_markup=get_keyboard())

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
        await update.message.reply_text(f"{CONNECTED_MSG} {data['username']}@{data['host']}", reply_markup=get_keyboard())
        channel.send("\n")
        log_session(chat_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        await update.message.reply_text(f"{CONNECTION_FAILED} {str(e)}", reply_markup=get_keyboard())

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
            await update.message.reply_text(PASTED_MSG, reply_markup=get_keyboard())
            context.user_data['awaiting_upload'] = False
        else:
            await update.message.reply_text(ONLY_TXT, reply_markup=get_keyboard())
    else:
        await update.message.reply_text(CONNECT_FIRST, reply_markup=get_keyboard())

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
    cat > bale/bot.py << BALECODE
#!/usr/bin/env python3

import threading
import time
import logging
import re
import paramiko
import json
import requests
from datetime import datetime

TOKEN = "$BALE_TOKEN"
API_URL = f"https://tapi.bale.ai/bot{TOKEN}/"
ALLOWED_IDS = [$BALE_USER_ID]

CONNECT_BTN = "$CONNECT_BTN"
DISCONNECT_BTN = "$DISCONNECT_BTN"
CTRL_C_BTN = "$CTRL_C_BTN"
CTRL_D_BTN = "$CTRL_D_BTN"
CTRL_X_BTN = "$CTRL_X_BTN"
CTRL_X_Y_BTN = "$CTRL_X_Y_BTN"
CTRL_X_N_BTN = "$CTRL_X_N_BTN"
CLEAR_BTN = "$CLEAR_BTN"
UPLOAD_BTN = "$UPLOAD_BTN"
LAST_50_BTN = "$LAST_50_BTN"
LAST_100_BTN = "$LAST_100_BTN"
ENTER_BTN = "$ENTER_BTN"
HELP_BTN = "$HELP_BTN"
RECONNECT_BTN = "$RECONNECT_BTN"
DEV_BTN = "$DEV_BTN"

START_MSG = "$START_MSG"
CONNECT_PROMPT = "$CONNECT_PROMPT"
PORT_PROMPT = "$PORT_PROMPT"
USERNAME_PROMPT = "$USERNAME_PROMPT"
PASSWORD_PROMPT = "$PASSWORD_PROMPT"
CONNECTED_MSG = "$CONNECTED_MSG"
CONNECTION_FAILED = "$CONNECTION_FAILED"
SESSION_CLOSED = "$SESSION_CLOSED"
NO_SESSION = "$NO_SESSION"
CTRL_SENT = "$CTRL_SENT"
SAVE_EXIT = "$SAVE_EXIT"
CANCEL = "$CANCEL"
CLEAR_MSG = "$CLEAR_MSG"
UPLOAD_MSG = "$UPLOAD_MSG"
PASTED_MSG = "$PASTED_MSG"
SENDING_LINES = "$SENDING_LINES"
ENTER_SENT = "$ENTER_SENT"
RECONNECT_MSG = "$RECONNECT_MSG"
ACCESS_DENIED = "$ACCESS_DENIED"
PRESS_CONNECT = "$PRESS_CONNECT"
ONLY_TXT = "$ONLY_TXT"
CONNECT_FIRST = "$CONNECT_FIRST"
HELP_TEXT = "$HELP_TEXT"
DEV_TEXT = "$DEV_TEXT"

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
            [CONNECT_BTN, DISCONNECT_BTN],
            [CTRL_C_BTN, CTRL_D_BTN],
            [CTRL_X_BTN, CTRL_X_Y_BTN],
            [CTRL_X_N_BTN, CLEAR_BTN],
            [UPLOAD_BTN, LAST_50_BTN],
            [LAST_100_BTN, ENTER_BTN],
            [HELP_BTN, RECONNECT_BTN],
            [DEV_BTN]
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
        send_message(chat_id, f"{CONNECTED_MSG} {data['username']}@{data['host']}", get_keyboard())
        channel.send("\n")
        log_session(user_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        send_message(chat_id, f"{CONNECTION_FAILED} {str(e)}", get_keyboard())

def process_message(chat_id, user_id, text):
    if text == CONNECT_BTN:
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, CONNECT_PROMPT, get_keyboard())
    elif text == DISCONNECT_BTN:
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            send_message(chat_id, SESSION_CLOSED, get_keyboard())
        else:
            send_message(chat_id, NO_SESSION, get_keyboard())
    elif text == CTRL_C_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x03')
        send_message(chat_id, f"Ctrl+C {CTRL_SENT}", get_keyboard())
    elif text == CTRL_D_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x04')
        send_message(chat_id, f"Ctrl+D {CTRL_SENT}", get_keyboard())
    elif text == CTRL_X_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18')
        send_message(chat_id, f"Ctrl+X {CTRL_SENT}", get_keyboard())
    elif text == CTRL_X_Y_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18Y\n')
        send_message(chat_id, f"Ctrl+X+Y {CTRL_SENT} ({SAVE_EXIT})", get_keyboard())
    elif text == CTRL_X_N_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18N\n')
        send_message(chat_id, f"Ctrl+X+N {CTRL_SENT} ({CANCEL})", get_keyboard())
    elif text == CLEAR_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[user_id]["channel"].send(b'\x7f')
        send_message(chat_id, CLEAR_MSG, get_keyboard())
    elif text == UPLOAD_BTN:
        user_steps[user_id] = {"step": "awaiting_upload"}
        send_message(chat_id, UPLOAD_MSG, get_keyboard())
    elif text == LAST_50_BTN and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -50\n")
        send_message(chat_id, f"{SENDING_LINES} 50...", get_keyboard())
    elif text == LAST_100_BTN and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -100\n")
        send_message(chat_id, f"{SENDING_LINES} 100...", get_keyboard())
    elif text == ENTER_BTN and user_id in sessions:
        sessions[user_id]["channel"].send(b'\n')
        send_message(chat_id, ENTER_SENT, get_keyboard())
    elif text == HELP_BTN:
        send_message(chat_id, HELP_TEXT, get_keyboard())
    elif text == RECONNECT_BTN:
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            time.sleep(1)
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, RECONNECT_MSG, get_keyboard())
    elif text == DEV_BTN:
        send_message(chat_id, DEV_TEXT, get_keyboard())
    elif text == "/start":
        send_message(chat_id, START_MSG, get_keyboard())
    elif user_id in user_steps:
        step = user_steps[user_id].get("step")
        if step == "host":
            user_steps[user_id]["host"] = text
            user_steps[user_id]["step"] = "port"
            send_message(chat_id, PORT_PROMPT, get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[user_id]["port"] = port
            user_steps[user_id]["step"] = "username"
            send_message(chat_id, USERNAME_PROMPT, get_keyboard())
        elif step == "username":
            user_steps[user_id]["username"] = text
            user_steps[user_id]["step"] = "password"
            send_message(chat_id, PASSWORD_PROMPT, get_keyboard())
        elif step == "password":
            password = text
            if text.startswith('@') or "'" in text or '"' in text:
                password = f"'{text}'"
            user_steps[user_id]["password"] = password
            do_ssh_connect(chat_id, user_id, user_steps[user_id])
            del user_steps[user_id]
    elif user_id in sessions:
        sessions[user_id]["channel"].send(text + "\n")
        log_session(user_id, f"CMD: {text}")
        send_message(chat_id, f"Command sent: {text}", get_keyboard())
    else:
        send_message(chat_id, PRESS_CONNECT, get_keyboard())

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
                    send_message(chat_id, PASTED_MSG, get_keyboard())
                else:
                    send_message(chat_id, CONNECT_FIRST, get_keyboard())
        del user_steps[user_id]
    else:
        send_message(chat_id, PRESS_CONNECT, get_keyboard())

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
                        send_message(chat_id, ACCESS_DENIED)
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
echo -e "${GREEN}Bot language: $([ $lang_choice == "1" ] && echo "Persian" || echo "English")${NC}"
