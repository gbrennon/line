FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    pkg-config \
    libasound2-dev \
    libjack-jackd2-dev \
    libreadline-dev \
    libpulse-dev \
    portaudio19-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install newer CMake (required for RtMidi)
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    echo 'deb https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null && \
    apt-get update && \
    apt-get install -y cmake && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Create build directory and build the project
RUN mkdir -p build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
    -DGIT_ACTION=ON \
    -DBUILD_17=ON \
    -DRTMIDI_API_JACK=ON \
    -DRTMIDI_BUILD_TESTING=OFF \
    .. && \
    make && \
    chmod +x line

# Create a non-root user for running the application
RUN useradd -m -s /bin/bash lineuser && \
    chown -R lineuser:lineuser /app

USER lineuser

# Set the default command
CMD ["./build/line"]
