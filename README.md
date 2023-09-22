1. Obtain your name.com API key: https://www.name.com/account/settings/api
2. Copy name.com-config.sh.example to name.com-config.sh and edit it.
3. Add a cron job to run the script every 5m:
    */5 * * * * ( cd /PATH/TO/REPO ; ./update-dns-if-ip-changed.sh >/dev/null 2>&1; ) >/dev/null 2>&1

