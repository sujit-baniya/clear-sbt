# https://hub.docker.com/r/adoptopenjdk/openjdk11
FROM amazoncorretto:11-alpine

LABEL maintainer="s.baniya.np@gmail.com"

RUN set -x \
  && apk --update add --no-cache --virtual .build-deps curl \
  && SBT_VER="1.8.2" \
  && ESUM="1f65344da074dbd66dfefa93c0eff8d319d772e5cad47fcbeb6ae178bbdf4686" \
  && SBT_URL="https://github.com/sbt/sbt/releases/download/v${SBT_VER}/sbt-${SBT_VER}.tgz" \
  && apk add shadow \
  && apk add bash \
  && apk add openssh \
  && apk add rsync \
  && apk add git \
  && curl -Ls ${SBT_URL} > /tmp/sbt-${SBT_VER}.tgz \
  && sha256sum /tmp/sbt-${SBT_VER}.tgz \
  && (echo "${ESUM}  /tmp/sbt-${SBT_VER}.tgz" | sha256sum -c -) \
  && mkdir /opt/sbt \
  && tar -zxf /tmp/sbt-${SBT_VER}.tgz -C /opt/sbt \
  && sed -i -r 's#run \"\$\@\"#unset JAVA_TOOL_OPTIONS\nrun \"\$\@\"#g' /opt/sbt/sbt/bin/sbt \
  && apk del --purge .build-deps \
  && rm -rf /tmp/sbt-${SBT_VER}.tgz /var/cache/apk/*

WORKDIR /opt/workspace

ENTRYPOINT ["sbt"]

ENV PATH="/opt/sbt/sbt/bin:$PATH" \
    JAVA_OPTS="-XX:+UseContainerSupport -Dfile.encoding=UTF-8" \
    SBT_OPTS="-Xmx2048M -Xss2M"

RUN set -x \
  && echo "ThisBuild / scalaVersion := \"2.12.17\"" >> build.sbt \
  && mkdir -p project \
  && echo "sbt.version=1.8.2" >> project/build.properties \
  && echo "object Test" >> Test.scala \
  && sbt compile \
  && sbt compile \
  && rm Test.scala \
  && rm -rf project \
  && rm -rf target \
  && rm build.sbt