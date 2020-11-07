# serveralerts2telegram

Every 5 minutes check the available disk space and server load. If any of them raise $LOAD_LIMIT or $DISK_LIMIT, your Telegram Bot sends an alert to $TELEGRAM_CHAT_ID. When come back under the limits sends another message.

All Telegram messages attach a file with uptime, df, top and iotop output.

Also save a load log in /var/log/loadmonitor/$(hostname).tsv that rotate every week for a year.

**Simple, useful, light and written in pure bash!**


## Instalation with interactive script

```bash
bash <(curl -s https://raw.githubusercontent.com/joker-x/serveralerts2telegram/main/INSTALL.bash)
```


## Configuration

All options can be set with environment variables. Only two are required:

**TELEGRAM_BOT_TOKEN**

**TELEGRAM_CHAT_ID**

To obtain them, you need to:

1. Get a bot token. To get one, contact the @BotFather bot and send the command /newbot. Follow the instructions.
2. Start a conversation with your bot or invite it into a group where you want it to send messages.
3. Find the chat ID for every chat you want to send messages to. Contact the @myidbot bot and send the /getid command to get your personal chat ID or invite it into a group and use the /getgroupid command to get the group chat ID. Group IDs start with a hyphen, supergroup IDs start with -100.
4. Alternatively, you can get the chat ID directly from the bot API. Send your bot a command in the chat you want to use, then check https://api.telegram.org/bot{YourBotToken}/getUpdates

**LIMIT_LOAD**
Integer. If puntual server load is greater than LIMIT_LOAD send an alert. By default: the number of cores minus 2.

**LIMIT_DISK**
Integer. If percent of use of a partition is greater than LIMIT_DISK send an alert. By default: 90 and test all mounted partitions.

**MOUNT_POINTS**
String (path). Only test the partitions with contain MOUNT_POINTS. You can set more than one mount point with space or | separator. Example: MOUNT_POINTS="/dev/sda1|/dev/sda2" or MOUNT_POINTS="/dev/sda1 /dev/sda2". By default: blank (check all mounted mount points)

**TELEGRAM_LANG**
String. Set the language of the telegram bot alerts. Now, only implements 'es' for Spanish and 'en' for English. By default: 'es'.

## loadlog2html

This script generate a google timeline chart with load log. If set HTML_FILE environmet variable in a path inside document root of webserver, you can see it online.

