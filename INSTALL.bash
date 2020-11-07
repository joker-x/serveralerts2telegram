#!/bin/bash

# Interactive bash script to install serveralerts2telegram 

TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
TELEGRAM_LANG=$TELEGRAM_LANG
LIMIT_LOAD=$LIMIT_LOAD
LIMIT_DISK=$LIMIT_DISK
MOUNT_POINTS=$MOUNT_POINTS


function commandFullPath() {
  echo "$(whereis -b $1 | grep -oE '/[/a-z-]*' | head -n 1)"
}

function installDependencies() {
  if [[ ! -z $(commandFullPath "apt-get") ]]
  then
    echo "Debian Linux or derivated detected"
    apt-get update
    apt-get install coreutils util-linux procps curl iotop logrotate hostname
  elif [[ ! -z $(commandFullPath "yum") ]]
  then
    echo "CentOS Linux detected"
    yum update
    yum install coreutils util-linux procps curl iotop logrotate hostname
  elif [[ ! -z $(commandFullPath "dnf") ]]
  then
    echo "Fedora Linux detected"
    dnf install coreutils util-linux procps curl iotop logrotate hostname
  elif [[ ! -z $(commandFullPath "pacman") ]]
  then
    echo "Arch Linux detected"
    pacman -Syy
    pacman -S coreutils util-linux procps-ng curl iotop logrotate hostname
  else
    echo "OS not supported"
    exit 1
  fi
#  exit 0
}

# MAIN

[ "$(id -u)" != "0" ] && echo "This script must be run as root" && exit 1

if [ "$1" != "--reconfigure" ]
then
  echo "1. Install dependencies"
  installDependencies
  [ $? -gt 0 ] && echo "ERR: Install dependencies failed" && exit 1

  echo "2. Download scripts"
  curl -so "/usr/local/sbin/serveralerts2telegram" "https://raw.githubusercontent.com/joker-x/serveralerts2telegram/main/serveralerts2telegram"
  chmod u+x /usr/local/sbin/serveralerts2telegram
  curl -so "/usr/local/bin/loadlog2html" "https://raw.githubusercontent.com/joker-x/serveralerts2telegram/main/loadlog2html"
  chmod +x /usr/local/bin/loadlog2html

  echo "3. Create log files"
  mkdir -p /var/log/loadmonitor
  touch "/var/log/loadmonitor/$(hostname).tsv"
  curl -so "/etc/logrotate.d/loadmonitor" "https://raw.githubusercontent.com/joker-x/serveralerts2telegram/main/loadmonitor.logrotate"

  echo "4. Configuration"
else
  echo "Reconfiguration..."
fi

if [[ -z "$TELEGRAM_BOT_TOKEN" || -z "$TELEGRAM_CHAT_ID" ]]
then
  cat << FIN

  #
  # How to get TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID
  #

  1. Get a bot token. To get one, contact the @BotFather bot and send the command /newbot. Follow the instructions.

  2. Start a conversation with your bot or invite it into a group where you want it to send messages.

  3. Find the chat ID for every chat you want to send messages to. Contact the @myidbot bot and send the /getid command to get your personal chat ID or invite it into a group and use the /getgroupid command to get the group chat ID. Group IDs start with a hyphen, supergroup IDs start with -100.

  4. Alternatively, you can get the chat ID directly from the bot API. Send your bot a command in the chat you want to use, then check https://api.telegram.org/bot{YourBotToken}/getUpdates


FIN
fi

while [ -z "$TELEGRAM_BOT_TOKEN" ]
do
  read -p "(required) TELEGRAM_BOT_TOKEN = " TELEGRAM_BOT_TOKEN
done

while [ -z "$TELEGRAM_CHAT_ID" ]
do
  read -p "(required) TELEGRAM_CHAT_ID = " TELEGRAM_CHAT_ID
done

[ -z "$TELEGRAM_LANG" ] && read -p "(optional) TELEGRAM_LANG = " TELEGRAM_LANG

[ -z "$LIMIT_LOAD" ] && read -p "(optional) LIMIT_LOAD = " LIMIT_LOAD

[ -z "$LIMIT_DISK" ] && read -p "(optional) LIMIT_DISK = " LIMIT_DISK

[ -z "$MOUNT_POINTS" ] && read -p "(optional) MOUNT_POINTS = " MOUNT_POINTS

CRONENTRY="*/5 * * * * root TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID LIMIT_LOAD=$LIMIT_LOAD LIMIT_DISK=$LIMIT_DISK MOUNT_POINTS=$MOUNT_POINTS TELEGRAM_LANG=$TELEGRAM_LANG /usr/local/sbin/serveralerts2telegram >/dev/null 2>&1"

# Delete old configuration
cp /etc/crontab /etc/crontab.backup
CLEANCRON=$(grep -v serveralerts2telegram /etc/crontab)
echo -e "$CLEANCRON" > /etc/crontab

# Add new configuration
echo -e "\n\n# serveralerts2telegram update at $(date)" >> /etc/crontab
echo "$CRONENTRY" >> /etc/crontab

echo "serveralerts2telegram installed successfull"

