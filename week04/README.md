# 4주차

> 셸 스크립트로 반복작업 자동화(백업), 브랜치→PR→merge, 네트워크 기본(IP/포트/DNS)

자동화 + 협업 + 네트워크까지 한번에 나감

## 셸 스크립트 (week04/test)

greet.sh - 인자 없으면 사용법 출력
```bash
./greet.sh
echo $?        # 1
./greet.sh 이름
echo $?        # 0
```
`[ $# -eq 0 ]` 괄호 안쪽 띄어쓰기 없으면 에러남

check.sh - 파일인지 폴더인지
```bash
./check.sh var.sh   # 파일
./check.sh /etc     # 디렉터리
./check.sh 없는거    # 없음
```
-f 파일 / -d 폴더 / -z 빈문자열 / -eq -gt -lt 숫자비교

var.sh
- `USERNAME = "홍길동"` 이렇게 띄우면 안됨
- `TODAY=$(date +%Y%m%d)`

## grep, 파이프 (중요!)
```bash
grep "ERROR" server.log
grep -c "ERROR" server.log    # 3개
grep -i error server.log      # 대소문자 무시
grep -v "INFO" server.log     # INFO 빼고
cat server.log | grep ERROR | wc -l
find . -name "*.sh"
```
파이프 = 앞 명령 출력을 뒤 명령 입력으로

## backup.sh
test 폴더 압축해서 backups/에 날짜_PID.tar.gz로 저장
feature/backup-log 브랜치에서 로그 남기는 부분 추가함

```bash
echo "$(date '+%Y-%m-%d %H:%M:%S') 백업 완료: $FILENAME" >> "$BACKUP_DIR/backup.log"
```
- `>`는 덮어쓰기, `>>`는 뒤에 추가
- 백업 결과물은 깃에 안올림 → .gitignore에 backups/, restore-check/
- 복원확인 : tar -xzf로 풀고 `diff -rq test restore-check/test` 0 나오면 같은거

## 프로세스
```bash
sleep 300 &
jobs
ps aux | grep sleep
kill PID       # 15 SIGTERM 정상종료 요청
kill -9 PID    # 9 SIGKILL 강제. 최후의 수단
```

## Git 협업
브랜치 → 커밋/push → PR → merge
같은 줄을 두 브랜치에서 다르게 고치면 conflict

```
<<<<<<< HEAD
echo "[완료] 로그 기록"
=======
echo "로그 기록"
>>>>>>> origin/master
```
깃이 망가진게 아니라 둘 중에 뭐 쓸지 사람이 고르라는 것
표시 3줄 지우고 남길거만 남김 → add → commit → push

## 네트워크
- IP = 건물주소 / 포트 = 몇호
- 127.0.0.1 나 자신, 0.0.0.0 모든 인터페이스
- DNS 도메인 → IP

```bash
dig cs.inhatc.ac.kr +short
ping -c 4 8.8.8.8
curl -I https://cs.inhatc.ac.kr   # 400이어도 응답 왔으면 통신은 된거
```
ping 안돼도 서버 죽은거 아님 (방화벽에서 ICMP 막는 경우 많음)

```bash
python3 -m http.server 8080
curl -I http://localhost:8080          # 200
lsof -nP -iTCP -sTCP:LISTEN | grep 8080  # 맥은 ss 없어서 이걸로
```
같은 포트로 하나 더 띄우면 Address already in use → 다른 포트 쓰거나 kill

## 정리
셸 스크립트에 인자($1, $#), 조건문([ -f ], [ -d ], -eq), 반복문을 쓰면 상황에 따라 다르게 동작하는 자동화를 만들 수 있다. grep, find, 파이프(|)를 조합하면 로그에서 필요한 줄만 골라내거나 개수를 셀 수 있다. 이걸 묶어서 폴더를 날짜별로 압축하고 기록을 남기는 백업 스크립트를 만들었고, 백업 결과물처럼 저장소에 필요 없는 건 .gitignore로 제외한다.

협업은 main에 직접 올리지 않고 브랜치에서 작업한 뒤 PR로 합쳐달라고 요청하는 방식이다. 두 브랜치가 같은 줄을 다르게 고치면 conflict가 나는데, Git이 어느 쪽을 남길지 마음대로 정하지 않기 때문에 사람이 표시를 지우고 골라야 한다.

네트워크에서 IP는 컴퓨터를 찾는 주소, 포트는 그 컴퓨터 안의 서비스를 구분하는 번호, DNS는 도메인을 IP로 바꿔주는 역할이다. 같은 포트를 두 프로그램이 쓰면 충돌이 나서 다른 포트를 쓰거나 기존 프로세스를 종료해야 한다.

## 주의!
- 맥은 `sed -i ''` / ss 대신 lsof
- backup-log 브랜치 push만 하고 PR 안 열어서 master엔 반영 안 됐었음. push ≠ merge
