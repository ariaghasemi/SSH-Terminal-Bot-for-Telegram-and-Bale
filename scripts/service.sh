#!/bin/bash
case $1 in
    start)
        systemctl start telegram-ssh-bot
        systemctl start bale-ssh-bot
        ;;
    stop)
        systemctl stop telegram-ssh-bot
        systemctl stop bale-ssh-bot
        ;;
    restart)
        systemctl restart telegram-ssh-bot
        systemctl restart bale-ssh-bot
        ;;
    status)
        systemctl status telegram-ssh-bot --no-pager
        systemctl status bale-ssh-bot --no-pager
        ;;
    logs)
        journalctl -u telegram-ssh-bot -f
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status|logs}"
        ;;
esac
