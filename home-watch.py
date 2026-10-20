#!/usr/bin/env python3
"""Make the Home button open the launcher instead of LG's home.

webOS does not let an app replace Home, or even see which app is in front, so this runs in the
Home Assistant add-on. It watches the foreground app over the TV's remote-control service and,
the moment LG's home appears, launches the launcher on top.

Press Home twice within ESCAPE_SECONDS to stay on LG's home (for its menus).

    python3 home-watch.py 192.168.1.50
"""
import asyncio
import json
import os
import sys
import time

import lgtv

LAUNCHER = "com.gathin.tvhome"
LG_HOME = "com.webos.app.home"
ESCAPE_SECONDS = 3.0
# One Home press can report both signals (life event, then foreground): treat them as one press.
SAME_PRESS_SECONDS = 1.0
# App life events that come before LG's home is on screen, when the TV exposes them.
LIFE_EVENTS = ("splash", "launch", "foreground")


def log(*args):
    print(time.strftime("%Y-%m-%d %H:%M:%S"), *args, flush=True)


async def watch(host):
    ws = await lgtv.session(host, ping_interval=10, ping_timeout=10)
    log("connected to", host)
    last_redirect = last_home = 0.0
    try:
        # Life events fire as LG's home starts, before it is on screen; the foreground app only once
        # it shows. Not every firmware lets the remote service read life events: then the error is
        # logged and the foreground subscription alone does the job.
        await ws.send(json.dumps({"type": "subscribe", "id": "life",
                                  "uri": "ssap://com.webos.applicationManager/getAppLifeEvents",
                                  "payload": {}}))
        await ws.send(json.dumps({"type": "subscribe", "id": "fg",
                                  "uri": "ssap://com.webos.applicationManager/getForegroundAppInfo",
                                  "payload": {}}))
        async for raw in ws:
            msg = json.loads(raw)
            rid, payload = msg.get("id"), msg.get("payload", {})
            if msg.get("type") == "error":
                if rid == "launch":
                    log("launch failed (is the launcher installed?):", msg.get("error"))
                elif rid == "life":
                    log("app life events unavailable, using the foreground app only:", msg.get("error"))
                continue
            if rid == "life":
                if payload.get("appId") != LG_HOME or payload.get("event") not in LIFE_EVENTS:
                    continue
                via = "life event " + payload["event"]
            elif rid == "fg":
                if payload.get("appId") != LG_HOME:
                    continue
                via = "foreground"
            else:
                continue

            now = time.monotonic()
            if now - last_home < SAME_PRESS_SECONDS:
                continue
            last_home = now
            if now - last_redirect < ESCAPE_SECONDS:
                log("Home pressed twice: staying on LG home")
                last_redirect = 0.0
                continue
            last_redirect = now
            await ws.send(json.dumps({"type": "request", "id": "launch", "uri": "ssap://system.launcher/launch",
                                      "payload": {"id": LAUNCHER}}))
            log("LG home -> launcher, via", via)
    finally:
        await ws.close()


async def main(host):
    delay = 5
    while True:
        try:
            await watch(host)
            delay = 5
        except (OSError, asyncio.TimeoutError, lgtv.websockets.WebSocketException) as e:
            # TV off, in standby or off the network: keep trying, but back off.
            log("not connected:", type(e).__name__, e)
            delay = min(delay * 2, 20)
        await asyncio.sleep(delay)


if __name__ == "__main__":
    host = sys.argv[1] if len(sys.argv) > 1 else os.environ.get("TV_HOST")
    if not host:
        sys.exit("usage: home-watch.py <TV IP>")
    try:
        asyncio.run(main(host))
    except KeyboardInterrupt:
        pass
