#!/bin/sh
# web 컨테이너가 죽는 순간(die 이벤트)을 감지해서 바로 다시 켜는 감시자
# docker events : 도커에서 일어나는 일을 실시간으로 계속 출력
# | while read  : 한 줄(=이벤트 하나) 들어올 때마다 실행

echo "[watcher] web 감시 시작"

docker events \
  --filter label=com.docker.compose.project=guestbook \
  --filter label=com.docker.compose.service=web \
  --filter event=die \
  --format '{{.Actor.Attributes.name}}' |
while read NAME; do
  echo "[watcher] $(date '+%H:%M:%S') $NAME 종료 감지 -> 재시작"
  docker start "$NAME" > /dev/null && echo "[watcher] $NAME 다시 실행됨"
done
