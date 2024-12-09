# ARM64용 베이스 이미지 (Raspberry Pi에서 실행 가능)
FROM arm64v8/ubuntu:24.04

# 1. 비대화형 설치 모드 설정
ENV DEBIAN_FRONTEND=noninteractive

# 2. 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gdb \
    wget \
    vim \
    unzip \
    libopencv-dev \
    libomp-dev \
    git \
    meson \
    ninja-build \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    pkg-config \
    libboost-dev \
    libcamera-dev \
    libjpeg-dev \
    && apt-get clean

# 3. ncnn 다운로드 및 빌드
RUN git clone --depth=1 https://github.com/Tencent/ncnn.git && \
    cd ncnn && \
    mkdir build && \
    cd build && \
    cmake -D NCNN_DISABLE_RTTI=OFF -D NCNN_BUILD_TOOLS=ON \
    -D CMAKE_TOOLCHAIN_FILE=../toolchains/aarch64-linux-gnu.toolchain.cmake .. && \
    make -j4 && \
    make install && \
    mkdir /usr/local/lib/ncnn && \
    cp -r install/include/ncnn /usr/local/include/ncnn && \
    cp -r install/lib/libncnn.a /usr/local/lib/ncnn/libncnn.a

# 4. eigen-3.3.9 설치 (구글 드라이브에서 다운로드)
RUN wget --no-check-certificate 'https://drive.google.com/uc?export=download&id=1rqO74CYCNrmRAg8Rra0JP3yZtJ-rfket' -O eigen-3.3.9.zip

# 5. Eigen 압축 해제 및 빌드
RUN unzip eigen-3.3.9.zip && \
    cd eigen-3.3.9 && \
    mkdir build && cd build && \
    cmake .. && \
    make install

# 6. GitHub에서 NanoDet-Tracking-ncnn-RPi_64-bit.zip 파일 다운로드
RUN mkdir MyDir && cd MyDir && \
    wget https://github.com/Qengineering/NanoDet-Tracking-ncnn-RPi_64-bit/archive/refs/heads/main.zip -O main.zip && \
    unzip main.zip && \
    rm main.zip

# 7. 추가 Python버전
RUN apt-get update && apt-get install -y \
    python3-jinja2 \
    python3-yaml \
    python3-ply

# 8. libcamera 다운로드 및 빌드
RUN git clone --depth=1 https://git.libcamera.org/libcamera/libcamera.git && \
    cd libcamera && \
    meson setup build --buildtype=release && \
    meson compile -C build && \
    meson install -C build && \
    ldconfig

# 9. LCCV 라이브러리 다운로드 및 빌드
RUN git clone https://github.com/kbarni/LCCV.git && \
    cd LCCV && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j4 && \
    make install

# 10. 프로젝트 파일 복사
WORKDIR /mnt
COPY ./ /mnt

RUN apt-get update && apt-get install -y \
    raspi-config
# COPY raspberrypi-kernel-headers*.deb /mnt/
# COPY libcamera-apps*.deb /mnt/
    
#     # 패키지 설치
# RUN dpkg -i /mnt/raspberrypi-kernel-headers*.deb && \
#     dpkg -i /mnt/libcamera-apps*.deb && \
#     apt-get install -f
# 11. 실행 파일 설정
CMD ["./my_program"] \
CMD ["bash", "-c", "libcamera-docker"]
