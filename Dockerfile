FROM ubuntu:18.04

MAINTAINER behdad.222 <behdad.222@gmail.com>

ENV SDK_TOOLS_VERSION "4333796"
ENV GRADLE_VERSION "4.4"

ENV ANDROID_HOME "/android-sdk-linux"
ENV PATH "$PATH:${ANDROID_HOME}/tools"

RUN apt-get update \
	&& apt-get upgrade -y \
	&& apt-get install -y openjdk-8-jdk \
	&& apt-get install -y git wget unzip curl jq npm gradle zip \
	&& apt-get clean

RUN wget --output-document=gradle-${GRADLE_VERSION}-all.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip \
	&& mkdir -p ${ANDROID_HOME} \
	&& wget --output-document=android-sdk.zip https://dl.google.com/android/repository/sdk-tools-linux-${SDK_TOOLS_VERSION}.zip \
	&& unzip ./android-sdk.zip -d ${ANDROID_HOME} \
	&& rm ./android-sdk.zip \
	&& mkdir ~/.android \
	&& touch ~/.android/repositories.cfg

RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
	&& ${ANDROID_HOME}/tools/bin/sdkmanager --update

ADD packages.txt .
RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < ./packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}

RUN npm install -g cordova

RUN npm install --save-dev ci-publish
