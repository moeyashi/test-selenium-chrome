FROM python:3.12-slim AS python-base

ENV PYTHONUNBUFFERED=1 \
  \
  PIP_NO_CACHE_DIR=off \
  PIP_DISABLE_PIP_VERSION_CHECK=on \
  PIP_DEFAULT_TIMEOUT=100 \
  \
  POETRY_VERSION=1.8.3 \
  POETRY_HOME="/opt/poetry" \
  POETRY_VIRTUALENVS_CREATE=false \
  \
  PYSETUP_PATH="/opt/pysetup" \
  \
  LANGUAGE=ja_JP.UTF-8 \
  LANG=ja_JP.UTF-8

ENV PATH="$POETRY_HOME/bin:$PATH"

# Chromeの依存関係をインストール
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  wget \
  gnupg \
  libpq-dev \
  locales \
  && locale-gen ja_JP.UTF-8 \
  && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-chrome-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-archive-keyring.gpg] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
  google-chrome-stable \
  # `locale-gen ja_JP.UTF-8`をしてから実行する必要がある
  fonts-ipafont \
  # Chrome本体はSelenium-Managerが行うため不要なので消す
  && apt-get remove -y google-chrome-stable \
  && rm -rf /var/lib/apt/lists/*

FROM python-base AS initial
# 開発環境で必要なpackage、設定
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  curl \
  build-essential \
  git \
  openssh-server \
  && curl -sSL https://install.python-poetry.org | python3

WORKDIR $PYSETUP_PATH

FROM initial AS development-base
ENV POETRY_NO_INTERACTION=1
COPY poetry.lock pyproject.toml ./

FROM development-base AS development
RUN poetry install

WORKDIR /app

FROM development-base AS builder-base
RUN poetry install --no-dev

FROM python-base AS production
COPY --from=builder-base /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY ./main.py /app/main.py
WORKDIR /app

CMD ["python", "main.py"]
