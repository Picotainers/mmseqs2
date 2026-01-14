FROM debian:trixie AS builder
# install dependencies 
RUN apt-get update && \ 
    apt-get install -y build-essential git zlib1g-dev gcc g++ binutils make autoconf automake cmake libbz2-dev libatomic1 upx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/soedinglab/MMseqs2.git && \
    cd MMseqs2 && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make  && \
    cd src && \
    for LIB in $(ldd mmseqs | awk '{if (match($3,"/")){ print $3 }}'); do LIB_NAME=$(basename "$LIB"); cp "$LIB" "./$LIB_NAME"; done && \
    upx -9 mmseqs 
   


FROM gcr.io/distroless/base

COPY --from=builder /MMseqs2/build/src/mmseqs /usr/local/bin/
COPY --from=builder /MMseqs2/build/src/*.so* /lib/x86_64-linux-gnu/



ENTRYPOINT ["/usr/local/bin/mmseqs"]
