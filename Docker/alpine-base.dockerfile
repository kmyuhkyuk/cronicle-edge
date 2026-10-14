# build: docker build --no-cache -t cronicle/base-alpine -f Docker/alpine-base.dockerfile .
# docker tag cronicle/base-alpine cronicle/base-alpine:v3.24.1
# docker push cronicle/base-alpine 
# docker push cronicle/base-alpine:v3.24.1

# multi-arch build
# docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 -t cronicle/base-alpine:v3.24.1 --push -f Docker/alpine-base.dockerfile .

FROM python:alpine3.24
RUN apk add --no-cache bash nodejs tini util-linux bash openssl procps coreutils curl tar jq busybox-extras

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY requirements-pre.txt /tmp/
RUN pip install --no-cache-dir --pre -r /tmp/requirements-pre.txt