FROM python:3.12-slim
RUN apt-get update && apt-get install -y nodejs tini procps curl jq