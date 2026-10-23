# 3주차 - 셸 스크립팅

> Ollama로 qwen 모델 띄워서 웹으로 대화해보고, 실행 과정을 start.sh로 묶음

같은 명령어 매번 치기 귀찮고 실수함 → 파일로 만들어두기

## Ollama + qwen
```bash
ollama pull qwen3:0.6b
ollama list
curl http://127.0.0.1:11434/api/tags
```
- Ollama가 11434 포트에서 모델 돌림
- chat.py(LMS 파일)가 8000 포트로 웹페이지 띄우고 질문을 Ollama한테 넘김
- 브라우저 localhost:8000 → chat.py → Ollama → qwen3:0.6b

0.6b 모델이라 답이 좀 이상함. 오늘은 답변 퀄리티 보는게 아니라 켜고 끄는 흐름 보는거

## start.sh
```bash
#!/bin/bash
cd "$(dirname "$0")" || exit 1
exec python3 chat.py
```
- `#!/bin/bash` 셔뱅. bash로 실행하라는 뜻 (#하나면 그냥 주석)
- `$0` 실행한 스크립트 경로, `dirname`으로 폴더만 뽑음 → 어디서 실행해도 그 폴더로 감
- `|| exit 1` 앞에꺼 실패하면 1 남기고 종료
- `exec` bash를 python으로 아예 바꿈. 그래서 exec 밑에 echo 써도 안나옴

```bash
./start.sh          # Permission denied
ls -l               # -rw-r--r-- x가 없음
chmod u+x start.sh
./start.sh
```
그냥 `start.sh`라고 치면 안되고 `./` 붙여야됨 (PATH에서 찾기 때문)

## 환경변수로 바꾸기
start_with_export.sh → MODEL 지정
start_port_8080.sh → WEB_PORT=8080

```bash
#!/bin/bash
cd "$(dirname "$0")" || exit 1
export WEB_PORT="8080"
exec ./start.sh
```
chat.py 안 고치고 포트만 바뀜. export는 스크립트 안에서만 먹고 내 터미널은 그대로

## 메모
- `$1 $2` 인자, `$#` 인자개수, `$?` 직전 종료코드
- 종료코드 0 = 성공 (숫자 0 = false랑 반대라 헷갈림)
- `>/dev/null 2>&1` 출력이랑 에러 둘다 버림
- `command -v python3` 명령어 있는지 확인할때
- heredoc `<< 'EOF'` 따옴표 있으면 $변수가 글자 그대로 들어감

## 정리
자주 쓰는 명령어를 파일 하나에 적어두고 실행하는 게 셸 스크립트다. 사람이 매번 치면 순서를 바꾸거나 오타를 내지만, 스크립트는 몇 번을 돌려도 똑같이 실행된다.

스크립트 첫 줄의 셔뱅(#!/bin/bash)은 어떤 프로그램으로 해석할지 알려주고, 실행하려면 chmod로 실행 권한(x)을 줘야 한다. `cd "$(dirname "$0")"`를 쓰면 어디서 실행하든 스크립트가 있는 폴더 기준으로 동작하고, `|| exit 1`로 실패하면 바로 멈추게 할 수 있다. 명령어는 끝나면 종료 코드를 남기는데 0이 성공, 나머지가 실패다.

Ollama로 띄운 로컬 AI(qwen)를 실행하는 과정을 스크립트로 묶었고, export로 환경 변수를 넘기면 코드를 고치지 않아도 모델이나 포트 같은 실행 설정을 바꿀 수 있다.

## 주의!
- 그냥 `start.sh` 말고 `./start.sh`
- 만들자마자 실행하면 Permission denied → chmod u+x
