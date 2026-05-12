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

echo -e "${YELLOW}Select bot language:${NC}"
echo "1) Persian (فارسی)"
echo "2) English"
read -p "Enter your choice [1-2]: " lang_choice

if [[ $lang_choice -eq 1 ]]; then
    BOT_LANG="fa"
    echo -e "${GREEN}Language set to Persian${NC}"
else
    BOT_LANG="en"
    echo -e "${GREEN}Language set to English${NC}"
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

TOKEN = "REPLACE_TOKEN"
ALLOWED_IDS = [int(REPLACE_USER_ID)]
BOT_LANG = "REPLACE_LANG"

logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

sessions = {}
user_steps = {}

def log_session(chat_id, message):
    with open("telegram_sessions.log", "a", encoding="utf-8") as f:
        f.write(f"[{datetime.now()}] [{chat_id}] {message}\n")

def clean_ansi(text):
    return re.sub(r'\x1B\[[0-?]*[ -/]*[@-~]', '', text)

def get_text(key):
    texts = {
        "connect_btn": ["🔌 اتصال", "🔌 Connect"],
        "disconnect_btn": ["❌ قطع اتصال", "❌ Disconnect"],
        "ctrl_c_btn": ["⛔ Ctrl+C", "⛔ Ctrl+C"],
        "ctrl_d_btn": ["🔚 Ctrl+D", "🔚 Ctrl+D"],
        "ctrl_x_btn": ["💾 Ctrl+X", "💾 Ctrl+X"],
        "ctrl_xy_btn": ["💾 Ctrl+X+Y", "💾 Ctrl+X+Y"],
        "ctrl_xn_btn": ["🚫 Ctrl+X+N", "🚫 Ctrl+X+N"],
        "clear_btn": ["🧹 پاک کردن فایل", "🧹 Clear File"],
        "upload_btn": ["📤 آپلود و پیست", "📤 Upload & Paste"],
        "last50_btn": ["🔁 50 خط آخر", "🔁 Last 50 Lines"],
        "last100_btn": ["🔁 100 خط آخر", "🔁 Last 100 Lines"],
        "enter_btn": ["⏎ Enter", "⏎ Enter"],
        "help_btn": ["📋 راهنما", "📋 Help"],
        "reconnect_btn": ["🔄 اتصال مجدد", "🔄 Reconnect"],
        "dev_btn": ["👨‍💻 توسعه دهنده", "👨‍💻 Developer"],
        "start_text": ["🤖 ربات ترمینال SSH\nاز دکمه‌های زیر استفاده کن", "🤖 SSH Terminal Bot\nUse buttons below"],
        "enter_host": ["آدرس IP یا هاست سرور را وارد کن:", "Enter server IP or hostname:"],
        "enter_port": ["پورت SSH (پیش‌فرض 22):", "Enter SSH port (default 22):"],
        "enter_user": ["نام کاربری:", "Enter username:"],
        "enter_pass": ["رمز عبور:", "Enter password:"],
        "connected": ["✅ متصل شدی به", "✅ Connected to"],
        "conn_failed": ["❌ خطا در اتصال:", "❌ Connection failed:"],
        "closed": ["🔌 جلسه SSH بسته شد", "🔌 SSH session closed"],
        "no_session": ["هیچ جلسه فعالی نیست", "No active session"],
        "ctrl_c_sent": ["⛔ Ctrl+C ارسال شد", "⛔ Ctrl+C sent"],
        "ctrl_d_sent": ["🔚 Ctrl+D ارسال شد", "🔚 Ctrl+D sent"],
        "ctrl_x_sent": ["💾 Ctrl+X ارسال شد", "💾 Ctrl+X sent"],
        "ctrl_xy_sent": ["💾 Ctrl+X+Y ارسال شد (ذخیره و خروج)", "💾 Ctrl+X+Y sent (save & exit)"],
        "ctrl_xn_sent": ["🚫 Ctrl+X+N ارسال شد (لغو تغییرات)", "🚫 Ctrl+X+N sent (cancel)"],
        "clear_sent": ["🧹 تمام کدهای فایل پاک شد", "🧹 File content cleared"],
        "upload_prompt": ["📄 فایل txt ارسال کن تا در ترمینال پیست شود", "Send a .txt file to paste in terminal"],
        "upload_success": ["✅ محتوای فایل در ترمینال پیست شد", "✅ File content pasted in terminal"],
        "upload_invalid": ["❌ فقط فایل txt قبول می‌شود", "❌ Only .txt files are accepted"],
        "last50_sent": ["🔁 در حال ارسال 50 خط آخر...", "🔁 Sending last 50 lines..."],
        "last100_sent": ["🔁 در حال ارسال 100 خط آخر...", "🔁 Sending last 100 lines..."],
        "enter_sent": ["⏎ Enter ارسال شد", "⏎ Enter sent"],
        "reconnect_msg": ["🔄 در حال اتصال مجدد...\nآدرس IP را وارد کن:", "🔄 Reconnecting...\nEnter server IP:"],
        "press_connect": ["❌ ابتدا دکمه اتصال را بزن", "❌ Press Connect button first"],
        "cmd_sent": ["📤 دستور ارسال شد:", "📤 Command sent:"],
        "access_denied": ["⛔ دسترسی ندارید", "⛔ Access denied"],
        "help_text": [
            "راهنما:\nاتصال - اتصال به SSH\nCtrl+C - لغو فرمان\nCtrl+D - خروج از شل\nCtrl+X - خروج از ویرایشگر\nآپلود و پیست - ارسال فایل متنی\nخطوط آخر - نمایش تاریخچه",
            "Help:\nConnect - SSH connection\nCtrl+C - Interrupt\nCtrl+D - Exit shell\nCtrl+X - Exit editors\nUpload & Paste - Send text file\nLast Lines - Show history"
        ],
        "dev_info": [
            "👨‍💻 توسعه دهنده:\nتلگرام: @Aria_qi\nبله: @aria_qi\nگیت‌هاب: github.com/ariaghasemi",
            "👨‍💻 Developer:\nTelegram: @Aria_qi\nBale: @aria_qi\nGitHub: github.com/ariaghasemi"
        ]
    }
    idx = 0 if BOT_LANG == "fa" else 1
    return texts[key][idx]

def get_keyboard():
    keys = [
        [get_text("connect_btn"), get_text("disconnect_btn")],
        [get_text("ctrl_c_btn"), get_text("ctrl_d_btn")],
        [get_text("ctrl_x_btn"), get_text("ctrl_xy_btn")],
        [get_text("ctrl_xn_btn"), get_text("clear_btn")],
        [get_text("upload_btn"), get_text("last50_btn")],
        [get_text("last100_btn"), get_text("enter_btn")],
        [get_text("help_btn"), get_text("reconnect_btn")],
        [get_text("dev_btn")]
    ]
    return ReplyKeyboardMarkup(keys, resize_keyboard=True)

async def start(update, context):
    if update.effective_chat.id not in ALLOWED_IDS:
        await update.message.reply_text(get_text("access_denied"))
        return
    await update.message.reply_text(get_text("start_text"), reply_markup=get_keyboard())

async def handle_text(update, context):
    chat_id = update.effective_chat.id
    text = update.message.text

    if chat_id not in ALLOWED_IDS:
        return

    if text == get_text("connect_btn"):
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text(get_text("enter_host"), reply_markup=get_keyboard())
    elif text == get_text("disconnect_btn"):
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            await update.message.reply_text(get_text("closed"), reply_markup=get_keyboard())
        else:
            await update.message.reply_text(get_text("no_session"), reply_markup=get_keyboard())
    elif text == get_text("ctrl_c_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x03')
        await update.message.reply_text(get_text("ctrl_c_sent"), reply_markup=get_keyboard())
    elif text == get_text("ctrl_d_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x04')
        await update.message.reply_text(get_text("ctrl_d_sent"), reply_markup=get_keyboard())
    elif text == get_text("ctrl_x_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18')
        await update.message.reply_text(get_text("ctrl_x_sent"), reply_markup=get_keyboard())
    elif text == get_text("ctrl_xy_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18Y\n')
        await update.message.reply_text(get_text("ctrl_xy_sent"), reply_markup=get_keyboard())
    elif text == get_text("ctrl_xn_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x18N\n')
        await update.message.reply_text(get_text("ctrl_xn_sent"), reply_markup=get_keyboard())
    elif text == get_text("clear_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[chat_id]["channel"].send(b'\x7f')
        await update.message.reply_text(get_text("clear_sent"), reply_markup=get_keyboard())
    elif text == get_text("upload_btn"):
        context.user_data['awaiting_upload'] = True
        await update.message.reply_text(get_text("upload_prompt"), reply_markup=get_keyboard())
    elif text == get_text("last50_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -50\n")
        await update.message.reply_text(get_text("last50_sent"), reply_markup=get_keyboard())
    elif text == get_text("last100_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send("history | tail -100\n")
        await update.message.reply_text(get_text("last100_sent"), reply_markup=get_keyboard())
    elif text == get_text("enter_btn") and chat_id in sessions:
        sessions[chat_id]["channel"].send(b'\n')
        await update.message.reply_text(get_text("enter_sent"), reply_markup=get_keyboard())
    elif text == get_text("help_btn"):
        await update.message.reply_text(get_text("help_text"), reply_markup=get_keyboard())
    elif text == get_text("reconnect_btn"):
        if chat_id in sessions:
            sessions[chat_id]["channel"].close()
            sessions[chat_id]["ssh"].close()
            del sessions[chat_id]
            time.sleep(1)
        user_steps[chat_id] = {"step": "host"}
        await update.message.reply_text(get_text("reconnect_msg"), reply_markup=get_keyboard())
    elif text == get_text("dev_btn"):
        await update.message.reply_text(get_text("dev_info"), reply_markup=get_keyboard())
    elif chat_id in user_steps:
        step = user_steps[chat_id].get("step")
        if step == "host":
            user_steps[chat_id]["host"] = text
            user_steps[chat_id]["step"] = "port"
            await update.message.reply_text(get_text("enter_port"), reply_markup=get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[chat_id]["port"] = port
            user_steps[chat_id]["step"] = "username"
            await update.message.reply_text(get_text("enter_user"), reply_markup=get_keyboard())
        elif step == "username":
            user_steps[chat_id]["username"] = text
            user_steps[chat_id]["step"] = "password"
            await update.message.reply_text(get_text("enter_pass"), reply_markup=get_keyboard())
        elif step == "password":
            await do_ssh_connect(update, context, chat_id, user_steps[chat_id])
            del user_steps[chat_id]
    elif chat_id in sessions:
        sessions[chat_id]["channel"].send(text + "\n")
        log_session(chat_id, f"CMD: {text}")
        await update.message.reply_text(f"{get_text('cmd_sent')} {text}", reply_markup=get_keyboard())
    else:
        await update.message.reply_text(get_text("press_connect"), reply_markup=get_keyboard())

async def do_ssh_connect(update, context, chat_id, data):
    try:
        password = data["password"]
        if password.startswith("'") and password.endswith("'"):
            password = password[1:-1]
        
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=data["host"],
            port=data["port"],
            username=data["username"],
            password=password,
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
        await update.message.reply_text(f"{get_text('connected')} {data['username']}@{data['host']}", reply_markup=get_keyboard())
        channel.send("\n")
        log_session(chat_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        error_msg = str(e)
        if "password" in error_msg.lower():
            await update.message.reply_text(f"{get_text('conn_failed')} رمز اشتباه است. اگر رمز با @ شروع می‌شود، آن را در ' ' قرار دهید", reply_markup=get_keyboard())
        else:
            await update.message.reply_text(f"{get_text('conn_failed')} {error_msg}", reply_markup=get_keyboard())

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
            await update.message.reply_text(get_text("upload_success"), reply_markup=get_keyboard())
            context.user_data['awaiting_upload'] = False
        else:
            await update.message.reply_text(get_text("upload_invalid"), reply_markup=get_keyboard())

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
    sed -i "s/REPLACE_LANG/$BOT_LANG/" telegram/bot.py

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
ALLOWED_IDS = [int(REPLACE_USER_ID)]
BOT_LANG = "REPLACE_LANG"

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

def get_text(key):
    texts = {
        "connect_btn": ["🔌 اتصال", "🔌 Connect"],
        "disconnect_btn": ["❌ قطع اتصال", "❌ Disconnect"],
        "ctrl_c_btn": ["⛔ Ctrl+C", "⛔ Ctrl+C"],
        "ctrl_d_btn": ["🔚 Ctrl+D", "🔚 Ctrl+D"],
        "ctrl_x_btn": ["💾 Ctrl+X", "💾 Ctrl+X"],
        "ctrl_xy_btn": ["💾 Ctrl+X+Y", "💾 Ctrl+X+Y"],
        "ctrl_xn_btn": ["🚫 Ctrl+X+N", "🚫 Ctrl+X+N"],
        "clear_btn": ["🧹 پاک کردن فایل", "🧹 Clear File"],
        "upload_btn": ["📤 آپلود و پیست", "📤 Upload & Paste"],
        "last50_btn": ["🔁 50 خط آخر", "🔁 Last 50 Lines"],
        "last100_btn": ["🔁 100 خط آخر", "🔁 Last 100 Lines"],
        "enter_btn": ["⏎ Enter", "⏎ Enter"],
        "help_btn": ["📋 راهنما", "📋 Help"],
        "reconnect_btn": ["🔄 اتصال مجدد", "🔄 Reconnect"],
        "dev_btn": ["👨‍💻 توسعه دهنده", "👨‍💻 Developer"],
        "start_text": ["🤖 ربات ترمینال SSH\nاز دکمه‌های زیر استفاده کن", "🤖 SSH Terminal Bot\nUse buttons below"],
        "enter_host": ["آدرس IP یا هاست سرور را وارد کن:", "Enter server IP or hostname:"],
        "enter_port": ["پورت SSH (پیش‌فرض 22):", "Enter SSH port (default 22):"],
        "enter_user": ["نام کاربری:", "Enter username:"],
        "enter_pass": ["رمز عبور:", "Enter password:"],
        "connected": ["✅ متصل شدی به", "✅ Connected to"],
        "conn_failed": ["❌ خطا در اتصال:", "❌ Connection failed:"],
        "closed": ["🔌 جلسه SSH بسته شد", "🔌 SSH session closed"],
        "no_session": ["هیچ جلسه فعالی نیست", "No active session"],
        "ctrl_c_sent": ["⛔ Ctrl+C ارسال شد", "⛔ Ctrl+C sent"],
        "ctrl_d_sent": ["🔚 Ctrl+D ارسال شد", "🔚 Ctrl+D sent"],
        "ctrl_x_sent": ["💾 Ctrl+X ارسال شد", "💾 Ctrl+X sent"],
        "ctrl_xy_sent": ["💾 Ctrl+X+Y ارسال شد (ذخیره و خروج)", "💾 Ctrl+X+Y sent (save & exit)"],
        "ctrl_xn_sent": ["🚫 Ctrl+X+N ارسال شد (لغو تغییرات)", "🚫 Ctrl+X+N sent (cancel)"],
        "clear_sent": ["🧹 تمام کدهای فایل پاک شد", "🧹 File content cleared"],
        "upload_prompt": ["📄 فایل txt ارسال کن تا در ترمینال پیست شود", "Send a .txt file to paste in terminal"],
        "upload_success": ["✅ محتوای فایل در ترمینال پیست شد", "✅ File content pasted in terminal"],
        "upload_invalid": ["❌ فقط فایل txt قبول می‌شود", "❌ Only .txt files are accepted"],
        "last50_sent": ["🔁 در حال ارسال 50 خط آخر...", "🔁 Sending last 50 lines..."],
        "last100_sent": ["🔁 در حال ارسال 100 خط آخر...", "🔁 Sending last 100 lines..."],
        "enter_sent": ["⏎ Enter ارسال شد", "⏎ Enter sent"],
        "reconnect_msg": ["🔄 در حال اتصال مجدد...\nآدرس IP را وارد کن:", "🔄 Reconnecting...\nEnter server IP:"],
        "press_connect": ["❌ ابتدا دکمه اتصال را بزن", "❌ Press Connect button first"],
        "cmd_sent": ["📤 دستور ارسال شد:", "📤 Command sent:"],
        "access_denied": ["⛔ دسترسی ندارید", "⛔ Access denied"],
        "help_text": [
            "راهنما:\nاتصال - اتصال به SSH\nCtrl+C - لغو فرمان\nCtrl+D - خروج از شل\nCtrl+X - خروج از ویرایشگر\nآپلود و پیست - ارسال فایل متنی\nخطوط آخر - نمایش تاریخچه",
            "Help:\nConnect - SSH connection\nCtrl+C - Interrupt\nCtrl+D - Exit shell\nCtrl+X - Exit editors\nUpload & Paste - Send text file\nLast Lines - Show history"
        ],
        "dev_info": [
            "👨‍💻 توسعه دهنده:\nتلگرام: @Aria_qi\nبله: @aria_qi\nگیت‌هاب: github.com/ariaghasemi",
            "👨‍💻 Developer:\nTelegram: @Aria_qi\nBale: @aria_qi\nGitHub: github.com/ariaghasemi"
        ]
    }
    idx = 0 if BOT_LANG == "fa" else 1
    return texts[key][idx]

def get_keyboard():
    return {
        "keyboard": [
            [get_text("connect_btn"), get_text("disconnect_btn")],
            [get_text("ctrl_c_btn"), get_text("ctrl_d_btn")],
            [get_text("ctrl_x_btn"), get_text("ctrl_xy_btn")],
            [get_text("ctrl_xn_btn"), get_text("clear_btn")],
            [get_text("upload_btn"), get_text("last50_btn")],
            [get_text("last100_btn"), get_text("enter_btn")],
            [get_text("help_btn"), get_text("reconnect_btn")],
            [get_text("dev_btn")]
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
        password = data["password"]
        if password.startswith("'") and password.endswith("'"):
            password = password[1:-1]
        
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(
            hostname=data["host"],
            port=data["port"],
            username=data["username"],
            password=password,
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
        send_message(chat_id, f"{get_text('connected')} {data['username']}@{data['host']}", get_keyboard())
        channel.send("\n")
        log_session(user_id, f"Connected to {data['username']}@{data['host']}:{data['port']}")
    except Exception as e:
        error_msg = str(e)
        if "password" in error_msg.lower():
            send_message(chat_id, f"{get_text('conn_failed')} رمز اشتباه است. اگر رمز با @ شروع می‌شود، آن را در ' ' قرار دهید", get_keyboard())
        else:
            send_message(chat_id, f"{get_text('conn_failed')} {error_msg}", get_keyboard())

def process_message(chat_id, user_id, text):
    if text == get_text("connect_btn"):
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, get_text("enter_host"), get_keyboard())
    elif text == get_text("disconnect_btn"):
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            send_message(chat_id, get_text("closed"), get_keyboard())
        else:
            send_message(chat_id, get_text("no_session"), get_keyboard())
    elif text == get_text("ctrl_c_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x03')
        send_message(chat_id, get_text("ctrl_c_sent"), get_keyboard())
    elif text == get_text("ctrl_d_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x04')
        send_message(chat_id, get_text("ctrl_d_sent"), get_keyboard())
    elif text == get_text("ctrl_x_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18')
        send_message(chat_id, get_text("ctrl_x_sent"), get_keyboard())
    elif text == get_text("ctrl_xy_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18Y\n')
        send_message(chat_id, get_text("ctrl_xy_sent"), get_keyboard())
    elif text == get_text("ctrl_xn_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x18N\n')
        send_message(chat_id, get_text("ctrl_xn_sent"), get_keyboard())
    elif text == get_text("clear_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\x01')
        time.sleep(0.1)
        sessions[user_id]["channel"].send(b'\x7f')
        send_message(chat_id, get_text("clear_sent"), get_keyboard())
    elif text == get_text("upload_btn"):
        user_steps[user_id] = {"step": "awaiting_upload"}
        send_message(chat_id, get_text("upload_prompt"), get_keyboard())
    elif text == get_text("last50_btn") and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -50\n")
        send_message(chat_id, get_text("last50_sent"), get_keyboard())
    elif text == get_text("last100_btn") and user_id in sessions:
        sessions[user_id]["channel"].send("history | tail -100\n")
        send_message(chat_id, get_text("last100_sent"), get_keyboard())
    elif text == get_text("enter_btn") and user_id in sessions:
        sessions[user_id]["channel"].send(b'\n')
        send_message(chat_id, get_text("enter_sent"), get_keyboard())
    elif text == get_text("help_btn"):
        send_message(chat_id, get_text("help_text"), get_keyboard())
    elif text == get_text("reconnect_btn"):
        if user_id in sessions:
            sessions[user_id]["channel"].close()
            sessions[user_id]["ssh"].close()
            del sessions[user_id]
            time.sleep(1)
        user_steps[user_id] = {"step": "host"}
        send_message(chat_id, get_text("reconnect_msg"), get_keyboard())
    elif text == get_text("dev_btn"):
        send_message(chat_id, get_text("dev_info"), get_keyboard())
    elif text == "/start":
        send_message(chat_id, get_text("start_text"), get_keyboard())
    elif user_id in user_steps:
        step = user_steps[user_id].get("step")
        if step == "host":
            user_steps[user_id]["host"] = text
            user_steps[user_id]["step"] = "port"
            send_message(chat_id, get_text("enter_port"), get_keyboard())
        elif step == "port":
            port = int(text) if text.isdigit() else 22
            user_steps[user_id]["port"] = port
            user_steps[user_id]["step"] = "username"
            send_message(chat_id, get_text("enter_user"), get_keyboard())
        elif step == "username":
            user_steps[user_id]["username"] = text
            user_steps[user_id]["step"] = "password"
            send_message(chat_id, get_text("enter_pass"), get_keyboard())
        elif step == "password":
            do_ssh_connect(chat_id, user_id, user_steps[user_id])
            del user_steps[user_id]
    elif user_id in sessions:
        sessions[user_id]["channel"].send(text + "\n")
        log_session(user_id, f"CMD: {text}")
        send_message(chat_id, f"{get_text('cmd_sent')} {text}", get_keyboard())
    else:
        send_message(chat_id, get_text("press_connect"), get_keyboard())

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
                    send_message(chat_id, get_text("upload_success"), get_keyboard())
                else:
                    send_message(chat_id, get_text("press_connect"), get_keyboard())
        del user_steps[user_id]
    else:
        send_message(chat_id, get_text("upload_prompt"), get_keyboard())

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
                        send_message(chat_id, get_text("access_denied"))
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
    sed -i "s/REPLACE_LANG/$BOT_LANG/" bale/bot.py

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

chmod +x install.sh
