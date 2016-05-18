git clone --depth 1 -b bvlc_inference https://github.com/flx42/caffe.git /caffe && \
    cd /caffe && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
          -DCUDA_ARCH_NAME=Manual -DCUDA_ARCH_BIN="${CUDA_ARCH}" -DCUDA_ARCH_PTX="${CUDA_ARCH}" \
          -DUSE_CUDNN=ON -DUSE_OPENCV=ON -DUSE_LEVELDB=OFF -DUSE_LMDB=OFF \
          -DBUILD_python=OFF -DBUILD_python_layer=OFF -DBUILD_matlab=OFF \
          -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DCUDA_NVCC_FLAGS="--default-stream per-thread -O3" && \
    make -j"$(nproc)" install && \
    make clean
