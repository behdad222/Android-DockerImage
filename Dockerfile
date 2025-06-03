FROM ubuntu:24.04

MAINTAINER behdad222 <behdad.222@gmail.com>

ARG GRADLE_VERSION=8.14.1
ARG SDK_TOOLS_VERSION=13114758
ARG SENTRY_CLI_VERSION=2.46.0
ARG WEBP_VERSION=1.5.0
ARG SVG2VECTOR=1.0.2
ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME "/android-sdk-linux"
ENV PATH "$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin:opt/webp/bin"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git jq wget unzip curl zip openjdk-21-jdk \
	&& apt-get clean

RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
        && mkdir -p /opt/gradle \
        && unzip gradle-${GRADLE_VERSION}-all.zip -d /opt/gradle \
        && rm ./gradle-${GRADLE_VERSION}-all.zip \
        && mkdir -p ${ANDROID_HOME} \
        && wget --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-linux-${SDK_TOOLS_VERSION}_latest.zip \
        && unzip ./android-sdk.zip -d ${ANDROID_HOME} \
        && rm ./android-sdk.zip \
        && mkdir -p ~/.android \
        && touch ~/.android/repositories.cfg \ 
        && wget --output-document=/usr/local/bin/sentry-cli https://github.com/getsentry/sentry-cli/releases/download/${SENTRY_CLI_VERSION}/sentry-cli-Linux-x86_64 \
        && chmod +x /usr/local/bin/sentry-cli \
	&& wget --output-document=webp.tar.gz https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-${WEBP_VERSION}-linux-x86-64.tar.gz \
        && tar xvf webp.tar.gz \
	&& mv libwebp* /opt/webp \
        && rm webp.tar.gz \
	&& wget --output-document=svg2vector.tar https://github.com/eitanliu/svg2vector/releases/download/${SVG2VECTOR}/svg2vector-${SVG2VECTOR}.tar \
        && tar xvf svg2vector.tar \
	&& mv svg2vector* /opt/svg2vector \
        && rm svg2vector.tar \
	

RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
        && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

ADD packages.txt .
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
    ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}
