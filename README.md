# SSH Terminal Bot for Telegram & Bale

ربات پیشرفته اتصال SSH به سرور لینوکس از طریق پیامرسان‌های تلگرام و بله  
امکان کنترل کامل ترمینال، ارسال فایل، پشتیبانی از کلیدهای کنترلی و کیبورد دائمی
--------------- donate ----------------

درصورتی که لطف داشتین میتونین از توسعه دهنده ها حمایت کنین تا امکانات و خدمت های بیشتر رو با انگیزه بیشتر انجام بدن❤

## https://daramet.com/Ariayemerta ##

---------------------------------------


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
- تلگرام
به BotFather@ در تلگرام پیام بده newbot/

نام و یوزرنیم ربات رو انتخاب کن

توکن دریافت شده را ذخیره کن

برای گرفتن آیدی عددی به userinfobot@ پیام بده start/

- پیامرسان بله
به BotFatherBale@ پیام بده newbot/

توکن را دریافت کن

برای آیدی عددی به IDMasterBot@ پیام بده start/

## نحوه استفاده

  بعد از نصب، ربات رو start/ کن

  دکمه اتصال را بزن

  آیپی سرور، پورت، نام کاربری و رمز را وارد کن

  مثل ترمینال واقعی از دکمه‌ها استفاده کن
## نصب سریع

```bash
bash <(curl -s https://raw.githubusercontent.com/ariaghasemi/SSH-Terminal-Bot-for-Telegram-and-Bale/main/install.sh)
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
### راهنما برای کد های طولانی ###


## 📤 آپلود و پیست کردن فایل در ترمینال

یکی از قابلیت‌های این ربات، امکان آپلود فایل متنی و پیست خودکار محتوا در ترمینال سرور هست. این ویژگی زمانی به کار میاد که می‌خوای محتوای یه فایل (مثل کد، کانفیگ یا اسکریپت) رو مستقیماً داخل فایلی که با nano یا vim باز کردی، قرار بدی.

### چطور کار می‌کنه؟

1. اول از طریق ربات به سرورت وصل شو.
2. یه فایل با پسوند `.txt` آماده کن (مثلاً `config.txt`).
3. دکمه **📤 Upload & Paste** رو بزن.
4. فایل txt رو برات آپلود کن.
5. ربات محتوا رو کاراکتر به کاراکتر توی ترمینال پیست می‌کنه.

### مثال واقعی

فرض کن می‌خوای یه فایل کانفیگ nginx رو روی سرور ایجاد کنی:

```bash
nano /etc/nginx/sites-available/my-site.conf
```
حالا فایل nginx-config.txt رو که روی گوشی یا کامپیوترت داری، از طریق ربات آپلود می‌کنی. ربات خط به خط محتوای فایل رو توی nano پیست می‌کنه. بعد کافیه Ctrl+X رو بزنی و Save کنی.

نکته مهم
فقط فایل‌های .txt قبول میشن.

حجم فایل نباید خیلی بزرگ باشه (پیشنهاد حداکثر ۵۰ کیلوبایت).

برای فایل‌های بزرگتر، از روش مستقیم cat > file.txt و سپس پیست کردن استفاده کن.





## رفع اشکال

### ربات پاسخ نمی‌دهد
```bash
systemctl status telegram-ssh-bot
journalctl -u telegram-ssh-bot -f
```
### خطای ModuleNotFoundError
```bash
cd /root/telegram_ssh_bot/telegram
source venv/bin/activate
pip install -r requirements.txt
systemctl restart telegram-ssh-bot
```
### اتصال SSH برقرار نمی‌شود
پورت 22 روی سرور مقصد باز باشد

فایروال سرور شما (UFW/iptables) اتصال خروجی را مسدود نکند

## توسعه‌دهنده
[ARIA yemerta] - [[GitHub Profile Link](https://github.com/ariaghasemi)]



