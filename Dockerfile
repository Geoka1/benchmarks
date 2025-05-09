FROM debian:12.7

WORKDIR /benchmarks

RUN apt update && apt install -y --no-install-recommends \
    sudo \
    tcpdump \
    curl \
    wget \
    unzip \
    samtools \
    minimap2 \
    bcftools \
    python3-pip \
    vim \
    ffmpeg unrtf imagemagick libarchive-tools libncurses5-dev libncursesw5-dev zstd liblzma-dev libbz2-dev zip unzip nodejs tcpdump \
    git \
    gpg

RUN useradd -m user && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
COPY . .

RUN pip3 install --break-system-packages \
scikit-learn \
kaggle

RUN chown -R user:user /benchmarks
RUN chmod +x /benchmarks/main.sh
USER user

RUN git config --global --add safe.directory /benchmarks
#TODO fix ownership issues

CMD ["bash"]
