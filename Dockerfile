FROM openjdk:8u181

RUN mkdir -p /android-sdk

# Install general dependencies
RUN dpkg --add-architecture i386 && apt-get update && apt-get install -yq \
    apt-transport-https \
    libncurses5:i386 \
    libstdc++6:i386 \
    software-properties-common \
    zlib1g:i386 \
    --no-install-recommends

# Setup ENV for android things
ENV ANDROID_HOME="/android-sdk"
ENV ANDROID_SDK="${ANDROID_HOME}"
ENV PATH="${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools:${ANDROID_SDK}/tools/bin:${PATH}"
RUN echo "export PATH=${PATH}" > /root/.profile

# Downdload and install Android SDK (https://developer.android.com/studio/ Command Line Tools section)
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
RUN curl -L "${ANDROID_SDK_URL}" -o /tmp/android-sdk-linux.zip && \
    unzip /tmp/android-sdk-linux.zip -d /tmp/ && \
    rm /tmp/android-sdk-linux.zip && \
    mv /tmp/tools ${ANDROID_HOME}/

ENV BUILD_TOOLS_VERSION 28.0.3

# Install Android SDK components
RUN yes | sdkmanager \
                     "platform-tools" \
                     "build-tools;${BUILD_TOOLS_VERSION}"

# Install images
RUN yes | sdkmanager --licenses && \
    yes | sdkmanager \
                     "platforms;android-22" \
                     "system-images;android-22;google_apis;x86" \
		     "platforms;android-23" \
                     "system-images;android-23;google_apis;x86" \
                     "platforms;android-24" \
                     "system-images;android-24;google_apis;x86" \
                     "platforms;android-25" \
                     "system-images;android-25;google_apis;x86" \
                     "platforms;android-26" \
                     "system-images;android-26;google_apis;x86" \
		     "platforms;android-27" \
                     "system-images;android-27;google_apis;x86" \
		     "platforms;android-28" \
                     "system-images;android-28;google_apis;x86" \

# Create emulators
RUN \
    echo "no" | avdmanager create avd -n e2e-android-22 -k "system-images;android-22;google_apis;x86"

# If not setup resolution, then we will get message about corrupted config
RUN \
    echo hw.lcd.height=1920 >> /root/.android/avd/e2e-android-22.avd/config.ini && \
    echo hw.lcd.width=1080 >> /root/.android/avd/e2e-android-22.avd/config.ini
