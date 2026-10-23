#!/bin/bash
# web 컨테이너를 항상 3개로 유지하는 감시 스크립트
# 사용법: ./keep_web3.sh [개수]   (기본 3)
cd "$(dirname "$0")" || exit 1

DESIRED=${1:-3}
INTERVAL=5
LOG="keep_web3.log"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker가 없습니다." >&2
  exit 1
fi

while true; do
  # 1) 실행 중인 web 개수 세기
  RUNNING=$(docker compose ps -q --status running web | wc -l)

  # 2) 모자라면 다시 채우기
  if [ "$RUNNING" -lt "$DESIRED" ]; then
    echo "$(date '+%F %T') web ${RUNNING}개 -> ${DESIRED}개로 복구" >> "$LOG"
    docker compose up -d --scale web="$DESIRED" --no-recreate web
  fi

  # 3) unhealthy인 web은 재시작
  for ID in $(docker compose ps -q web); do
    STATUS=$(docker inspect --format '{{.State.Health.Status}}' "$ID" 2>/dev/null)
    if [ "$STATUS" = "unhealthy" ]; then
      echo "$(date '+%F %T') $ID unhealthy -> 재시작" >> "$LOG"
      docker restart "$ID" >/dev/null
    fi
  done

  sleep "$INTERVAL"
done
