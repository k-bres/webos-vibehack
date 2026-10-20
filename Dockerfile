ARG BUILD_FROM
FROM $BUILD_FROM

RUN apk add --no-cache python3 py3-websockets nodejs npm \
 && npm install -g @webos-tools/cli@3.2.6

WORKDIR /opt/tv
COPY app app
COPY lgtv.py sync-apps.py home-watch.py install.sh run.sh ./
RUN chmod +x install.sh run.sh

CMD ["/opt/tv/run.sh"]
