FROM debian:trixie AS builder
# install dependencies 
RUN apt-get update && \
   apt-get install -y git zlib1g-dev gcc binutils make g++ autoconf automake cmake libbz2-dev libatomic1

RUN git clone https://github.com/soedinglab/MMseqs2.git && \
   cd MMseqs2 && \
   mkdir build && \
   cd build && \
   cmake -DCMAKE_BUILD_TYPE=Release .. && \
   make  && \
   cd src && \
   for LIB in $(ldd mmseqs | awk '{if (match($3,"/")){ print $3 }}'); do  LIB_NAME=$(basename "$LIB") cp "$LIB" "./$LIB_NAME"; done && \
   git clone https://github.com/upx/upx.git && \
    cd upx && \
    git submodule init && \
    git submodule update && \
    make -j && \
    cp build/release/upx /usr/local/bin/upx && \
    cd .. && \
    upx -9 mmseqs 
   


FROM gcr.io/distroless/base

COPY --from=builder /MMseqs2/build/src/mmseqs /usr/local/bin/
COPY --from=builder /MMseqs2/build/src/*.so* /lib/x86_64-linux-gnu/



ENTRYPOINT ["/usr/local/bin/mmseqs"]/
