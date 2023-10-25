FROM ubuntu:22.04

MAINTAINER behdad222 <behdad.222@gmail.com>

ARG GRADLE_VERSION=8.0
ARG SDK_TOOLS_VERSION=10406996
ARG DEBIAN_FRONTEND=noninteractive

ENV ANDROID_HOME "/android-sdk-linux"
ENV PATH "$PATH:${ANDROID_HOME}/tools:/opt/gradle/gradle-${GRADLE_VERSION}/bin"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y git jq wget unzip curl zip openjdk-17-jdk \
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
        && touch ~/.android/repositories.cfg

RUN yes | ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --licenses \
        && ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} --update

ADD packages.txt .
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
    ${ANDROID_HOME}/cmdline-tools/bin/sdkmanager --sdk_root=${ANDROID_HOME} ${PACKAGES}
