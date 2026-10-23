# ---------------------------------------------------------------
# 학생 과제: 아래 각 줄이 무엇을 하는지 주석으로 설명을 달아보세요.
# ---------------------------------------------------------------

# 베이스 이미지. 파이썬 3.12 깔려있는 가벼운(slim) 버전에서 시작
FROM python:3.12-slim

# 컨테이너 안에서 작업할 폴더. 없으면 만들고 cd 하는거랑 비슷
WORKDIR /app

# requirements.txt 만 먼저 복사 → 코드만 바뀌면 밑에 pip install은 캐시 재사용
COPY requirements.txt .
# 이미지 만들때(build) 한번 실행. flask, redis 설치
RUN pip install --no-cache-dir -r requirements.txt

# 나머지 코드 전부 복사 (.dockerignore에 있는건 제외)
# 코드는 자주 바뀌니까 뒤에 둠
COPY . .

# root 말고 일반 사용자 만들어서 그걸로 실행 (root로 돌리면 위험)
RUN useradd -m appuser
USER appuser

# 환경변수 기본값. app.py 기본값보다 우선, docker run -e 보다는 약함
ENV APP_TITLE="InhaTC DevOps 방명록" \
    THEME_COLOR="#0054A6"

# 5000번 쓴다는 메모일 뿐 실제로 열리진 않음 → run 할때 -p 8081:5000 해야됨
EXPOSE 5000

# 컨테이너 켤때마다 실행되는 명령 (RUN이랑 다름!)
CMD ["python", "app.py"]
