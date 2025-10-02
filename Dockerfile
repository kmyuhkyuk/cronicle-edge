# build: docker build --no-cache -t cronicle:bundle -f Dockerfile .
# docker tag cronicle:dev cronicle/cronicle:edge
# test run: docker run --rm -it  -p 3019:3012 -e CRONICLE_manager=1 cronicle:bundle bash
# then type manager or worker

# cronicle/base-alpine: 
# FROM alpine:3.19.1
# RUN apk add --no-cache bash nodejs tini util-linux bash openssl procps coreutils curl tar jq

FROM kmyuhkyuk/cronicle-base-debian as build
RUN apt-get update && apt-get install -y npm
COPY . /build
WORKDIR /build
RUN ./bundle /dist --mysql --pgsql --s3 --sqlite --tools

FROM kmyuhkyuk/cronicle-base-debian

COPY requirements.txt /tmp/
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY requirements-pre.txt /tmp/
RUN pip install --no-cache-dir --pre -r /tmp/requirements-pre.txt

# non root user for shell plugin
ARG CRONICLE_UID=1000
ARG CRONICLE_GID=1099
RUN addgroup --system --gid $CRONICLE_GID cronicle
RUN adduser --system --disabled-password --home /opt/cronicle --uid $CRONICLE_UID cronicle

COPY --from=build /dist /opt/cronicle

ENV PATH "/opt/cronicle/bin:${PATH}"
ENV CRONICLE_foreground=1
ENV CRONICLE_echo=1
ENV TZ=America/New_York 

WORKDIR /opt/cronicle 

# protect sensitive folders
RUN  mkdir -p /opt/cronicle/data /opt/cronicle/conf && chmod 0700 /opt/cronicle/data /opt/cronicle/conf

ENTRYPOINT ["/usr/bin/tini", "--"]
