# SSH Terminal Bot for Telegram & Bale

ربات پیشرفته اتصال SSH به سرور لینوکس از طریق پیامرسان‌های تلگرام و بله  
امکان کنترل کامل ترمینال، ارسال فایل، پشتیبانی از کلیدهای کنترلی و کیبورد دائمی

## قابلیت‌ها

- اتصال SSH به هر سرور لینوکس
- کیبورد ثابت پایین صفحه با دکمه‌های:
  - اتصال / قطع اتصال
  -پشتیبانی از  Ctrl+C, Ctrl+D, Ctrl+X
  - ذخیره و خروج در nano
  - پاک کردن کل فایل در ویرایشگر
  - آپلود فایل txt و پیست خودکار
  - نمایش 50 و 100 خط آخر
  - ارسال Enter خالی
  -خودکار reconnect
  - پشتیبانی از رمز عبور و کلید SSH
  - اجرای دائمی با systemd
  - ذخیره لاگ جلسات
  - محدودیت دسترسی با Whitelist

## پیش‌نیازها

- سرور لینوکس (Ubuntu/Debian/CentOS)
- دسترسی root یا sudo
- توکن ربات تلگرام از @BotFather
- توکن ربات بله از @BotFatherBale
- آیدی عددی کاربر (برای محدودیت دسترسی)

## دریافت توکن و آیدی
# تلگرام
به BotFather@ در تلگرام پیام بده newbot/

نام و یوزرنیم ربات رو انتخاب کن

توکن دریافت شده را ذخیره کن

برای گرفتن آیدی عددی به userinfobot@ پیام بده start/

# پیامرسان بله
به BotFatherBale@ پیام بده newbot/

توکن را دریافت کن

برای آیدی عددی به IDMasterBot@ پیام بده start/

نحوه استفاده
بعد از نصب، ربات رو start/ کن

دکمه اتصال را بزن

آیپی سرور، پورت، نام کاربری و رمز را وارد کن

مثل ترمینال واقعی از دکمه‌ها استفاده کن
## نصب سریع

```bash
bash <(curl -s https://raw.githubusercontent.com/YOUR-USERNAME/telegram-bale-ssh-bot/main/install.sh)
```
نصب‌کننده از تو میپرسه کدوم پیامرسان رو نصب کنی.
## لایسنس
MIT License - استفاده آزاد با ذکر منبع
### مدیریت سرویس‌ها
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
```
## توسعه‌دهنده
[ARIA yemerta] - [[GitHub Profile Link](https://github.com/ariaghasemi)]
