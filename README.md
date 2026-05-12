# SSH Terminal Bot for Telegram and Bale

ربات ترمینال SSH برای پیامرسان‌های تلگرام و بله | اتصال به سرور لینوکس مثل ترمینال واقعی

## ویژگی‌ها

- اتصال SSH به سرور لینوکس
- کیبورد ثابت پایین صفحه با دکمه‌های کاربردی
- پشتیبانی از Ctrl+C, Ctrl+D, Ctrl+X
- آپلود فایل txt و پیست خودکار در ترمینال
- پاک کردن محتوای فایل در ویرایشگر nano
- نمایش ۵۰ و ۱۰۰ خط آخر تاریخچه
- اجرا به عنوان سرویس systemd
- راه‌اندازی خودکار بعد از ریبوت

## راهنمای دریافت توکن و آیدی

### تلگرام
1. به @BotFather در تلگرام پیام بده `/newbot`
2. توکن دریافتی را ذخیره کن
3. برای گرفتن chat id به @userinfobot پیام بده

### پیامرسان بله
1. به @BotFather_Bale در بله پیام بده `/newbot`
2. توکن دریافتی را ذخیره کن
3. برای گرفتن user id به @IDMasterBot در بله پیام بده

## نصب

```bash
git clone https://github.com/YOUR_USERNAME/telegram-bale-ssh-bot.git
cd telegram-bale-ssh-bot
chmod +x install.sh
./install.sh
```

نصب‌کننده از تو میپرسه کدوم پیامرسان رو نصب کنی.

مدیریت سرویس‌ها
# تلگرام

```bash
systemctl status telegram-ssh-bot
systemctl restart telegram-ssh-bot
systemctl stop telegram-ssh-bot
```

# بله
```bash
systemctl status bale-ssh-bot
systemctl restart bale-ssh-bot
systemctl stop bale-ssh-bot
```

مشاهده لاگ
```bash
tail -f /root/telegram_ssh_bot/bot.log
tail -f /root/telegram_ssh_bot/bale_bot.log
