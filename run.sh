#!/usr/bin/with-contenv bashio
# Home Assistant add-on: install the launcher, keep Developer Mode alive, send Home to the launcher.
export HOME=/data LGTV_KEY_FILE=/data/lgtv-key.json
TV_HOST="$(bashio::config tv_host)"
PASS="$(bashio::config passphrase)"
export TV_HOST
cd /opt/tv

# The launcher config is editable from HA, in /addon_configs/<id>_webos_vibehack/config.js.
[ -f /config/config.js ] || cp app/config.js /config/config.js
cp /config/config.js app/config.js

# Developer Mode SSH key, fetched once: the Key Server switch must be on in the Developer Mode app.
if [ ! -s ~/.ssh/lgtv_webos ]; then
  mkdir -p ~/.ssh
  if curl -fsS "http://$TV_HOST:9991/webos_rsa" -o ~/.ssh/lgtv_webos; then
    chmod 600 ~/.ssh/lgtv_webos
  else
    rm -f ~/.ssh/lgtv_webos
    bashio::log.warning "Could not fetch the SSH key: turn on Key Server in the Developer Mode app, then restart."
  fi
fi
DEV="{'host':'$TV_HOST','port':'9922','username':'prisoner','privatekey':'lgtv_webos','passphrase':'$PASS'}"
ares-setup-device -a lgtv -i "$DEV" >/dev/null 2>&1 || ares-setup-device -m lgtv -i "$DEV" >/dev/null

if bashio::config.true install_on_start; then
  ./install.sh || bashio::log.warning "Install failed (TV off?). Restart the add-on to retry."
fi

# Developer Mode expires after 1000 h. Extend it weekly; the Developer Mode app flashes up, so
# prefer the night (works if the TV stays reachable in standby) unless it's getting close.
# ponytail: fixed 3-5 am window, make it an option if your TV is never reachable then.
(
  while true; do
    age=$(( $(date +%s) - $(cat /data/devmode-extended 2>/dev/null || echo 0) ))
    hour=$(date +%H)
    if [ "$age" -gt 604800 ] && { [ "$hour" -ge 3 ] && [ "$hour" -lt 5 ] || [ "$age" -gt 2592000 ]; }; then
      if ares-launch -d lgtv com.palmdts.devmode -p extend=true >/dev/null 2>&1; then
        date +%s > /data/devmode-extended
        bashio::log.info "Developer Mode session extended"
        sleep 5
        ares-launch -d lgtv --close com.palmdts.devmode >/dev/null 2>&1
      fi
    fi
    sleep 3600
  done
) &

exec python3 -u home-watch.py "$TV_HOST"
