# 6주차 Dockerfile

> 방명록 앱을 Dockerfile로 내 이미지로 만들고 ghcr.io에 올리기

컨테이너 안에서 고친건 지우면 날아감 → 그럼 아예 이미지로 만들자

## 이미지 주소
`ghcr.io/makyraen/inhatc-devops-guestbook:v1`
레지스트리 / 계정 / 이름 : 태그
태그 안쓰면 latest를 찾음 (최신버전 알아서 찾는거 아님. 그래서 처음에 not found 뜸)

## guestbook/Dockerfile
```dockerfile
FROM python:3.12-slim        # 베이스 이미지
WORKDIR /app                 # cd 같은거. 없으면 만듦
COPY requirements.txt .      # 라이브러리 목록 먼저
RUN pip install --no-cache-dir -r requirements.txt
COPY . .                     # 나머지 코드
RUN useradd -m appuser
USER appuser                 # root로 안 돌리려고
ENV APP_TITLE="InhaTC DevOps 방명록" \
    THEME_COLOR="#0054A6"
EXPOSE 5000                  # 메모일 뿐. -p 해야 열림
CMD ["python", "app.py"]
```
RUN = 이미지 만들때 1번
CMD = 컨테이너 켤때마다

```bash
cd ~/devops/guestbook
docker build -t guestbook:v1 .       # 마지막 . 빼먹으면 에러
docker run -d -p 8081:5000 --name gb guestbook:v1
```
그냥 `python3 app.py` 하면 flask 없다고 에러남. 도커로 하면 그런거 신경 안씀

## 캐시
index.html 빈 화면 문구 바꾸고 다시 빌드
```bash
sed -i '' 's/아직 방명록이 비어 있습니다./첫 글의 주인공이 되어주세요!/' templates/index.html
docker build -t guestbook:v1.2 .
```
맥은 sed -i 뒤에 '' 붙여야됨

pip install은 CACHED, COPY . . 부터 다시 함

Dockerfile.bad는 COPY . . 하고 pip install 순서라서
app.py에 `# 테스트` 한줄 추가한것만으로 pip install 처음부터 다시함
→ 자주 바뀌는 코드는 뒤에, 잘 안바뀌는 라이브러리는 앞에

## 환경변수 우선순위
코드 기본값(app.py) < Dockerfile ENV < docker run -e

- app.py 기본값은 "DevOps 방명록" 빨간색
- 실제 화면은 "InhaTC DevOps 방명록" 파란색 → Dockerfile ENV가 덮음
- -e로 주면 그게 제일 셈

```bash
docker run -d -p 8080:5000 --name demo \
  -e APP_TITLE="내 방명록" -e THEME_COLOR="#16a34a" \
  ghcr.io/makyraen/inhatc-devops-guestbook:v1
```
이미지 다시 안만들고 설정만 바꿀수있음

## 이미지 올리기
```bash
gh auth token | docker login ghcr.io -u Hwan028 --password-stdin
docker tag guestbook:v1 ghcr.io/hwan028/guestbook:v1
docker push ghcr.io/hwan028/guestbook:v1
```
패키지 public으로 바꿔야 친구가 받을 수 있음

맥(arm64)에서 빌드한 이미지는 윈도우(amd64)에서 안되거나 느릴수 있음
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/hwan028/guestbook:v1 --push .
```

## 남은 문제
restart 하면 방명록 글이 다 날아감. 화면에 저장소: Memory
글이 프로세스 메모리에만 있어서 → DB 필요

## 정리
컨테이너에서 바꾼 게 사라지는 문제는 변경 내용을 아예 이미지로 만들어서 해결할 수 있다. Dockerfile은 이미지를 어떻게 만들지 적은 레시피로 FROM, WORKDIR, COPY, RUN, ENV, EXPOSE, CMD 순서로 쓴다. RUN은 이미지를 만들 때 한 번, CMD는 컨테이너를 켤 때마다 실행되고, EXPOSE는 포트를 실제로 여는 게 아니라 어떤 포트를 쓰는지 적어두는 메모다.

Dockerfile의 각 줄은 레이어가 되고, 바뀌지 않은 레이어는 캐시를 재사용한다. 한 레이어가 바뀌면 그 아래는 다 다시 만들기 때문에 잘 안 바뀌는 라이브러리 설치를 앞에, 자주 바뀌는 코드 복사를 뒤에 두는 게 빌드가 빠르다.

설정은 코드 기본값 < Dockerfile ENV < docker run -e 순서로 덮어써서, 이미지를 다시 만들지 않고도 실행할 때 값을 바꿀 수 있다. 만든 이미지는 tag를 붙여 ghcr.io 같은 레지스트리에 push하면 다른 사람이 pull해서 그대로 실행할 수 있고, arm64(맥)와 amd64(윈도우)가 다르기 때문에 buildx로 둘 다 만들어 두는 게 좋다.

## 주의!
- build 끝에 점(.) 빼먹지 말기
- 맥에서 그냥 빌드하면 arm64 → 윈도우용은 buildx
- ghcr.io 이미지 이름은 소문자
