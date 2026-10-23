# 2주차

> WSL 대신 맥 터미널로 환경 맞추고, Git으로 커밋/브랜치/diff 해보고 GitHub에 레포 만들어서 push까지

실습 환경 구축 + Git 기초

## 가상화
- 베어메탈 : 하드웨어에 OS 깔고 프로그램 여러개 돌림. 하나 털리면 다 위험
- 하이퍼바이저 : VM마다 게스트 OS가 따로 있음 → 격리는 확실한데 무거움
- 컨테이너 : 호스트 OS 커널을 같이 씀. 가볍다
  - namespace = 서로 안 보이게
  - cgroups = 자원 못 쓰게 제한

수업은 윈도우 WSL 기준인데 나는 맥이라 WSL은 안하고 터미널(zsh)에서 바로 했음. 패키지는 brew로 설치

## 리눅스 명령어
```bash
ls -la          # 숨김파일까지 (.으로 시작하면 숨김)
chmod 755 a.sh  # r=4 w=2 x=1 → 7=rwx 5=r-x
!!              # 직전 명령 다시
sudo !!         # 직전 명령 sudo로
tail -f 로그     # 실시간으로 계속 보기
```

## Git
```bash
git init
echo "Hello, DevOps" > test.txt
git add test.txt
git commit -m "first commit"

echo "hello" > hello.txt
git add .
git commit -m "hello"
```

git add는 저장이 아니라 다음 커밋에 넣을거 고르는거(staging)

### 브랜치
```bash
git switch -c hi
echo "hi" > hello.txt
git add .         # 도마에 전체 다 올리기
git commit -m "hello -> hi"

git switch master
cat hello.txt     # hello
git switch hi
cat hello.txt     # hi
git diff master hi
```
hi 브랜치에서 바꾼게 master에는 없음. `git log --oneline --all --graph` 하면 갈라진게 보인다

내 레포는 기본 브랜치가 master임.. `git config --global init.defaultBranch main`을 init 하기 전에 했어야 됐는데 순서를 놓침

## GitHub
```bash
gh auth login
gh repo create devops --public --source=. --remote=origin --push
```
커밋하고 push 안하면 깃허브엔 안 올라감

## 정리
서버를 운영하는 방법은 크게 베어메탈, 하이퍼바이저, 컨테이너가 있다. 베어메탈은 구조가 단순하지만 프로그램끼리 격리가 안 되고, 하이퍼바이저는 VM마다 게스트 OS를 따로 둬서 격리는 확실하지만 무겁다. 컨테이너는 호스트 커널을 공유하면서 namespace로 서로 안 보이게, cgroups로 자원을 제한하는 방식이라 가볍다.

Git은 파일 변경 이력을 기록하는 도구이고 add로 다음 커밋에 넣을 걸 고른 뒤(staging) commit으로 버전을 확정한다. 커밋 해시로 예전 버전으로 이동하거나 diff로 비교할 수 있고, 브랜치를 만들면 원본(master)을 건드리지 않고 따로 작업할 수 있다. GitHub은 이 저장소를 온라인에 올려서 공유하고 협업하는 공간이고, 로컬에서 커밋한 건 push를 해야 올라간다.

## 주의!
- init 전에 defaultBranch 설정 안 해서 내 레포는 master로 만들어짐
- commit만 하고 push 안 하면 깃헙엔 없음
