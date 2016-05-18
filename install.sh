echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1404/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list
export CUDNN_VERSION=4
export CUDA_ARCH="30 35 52"

apt-get update && apt-get install -y --no-install-recommends --force-yes \


apt-get update && apt-get install -y --no-install-recommends --force-yes \
	libcudnn4-dev=4.0.7 \
        ca-certificates \
        cmake \
        git \
        libatlas-base-dev \
        libatlas-dev \
        libboost-all-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        libhdf5-dev \
        libprotobuf-dev \
        pkg-config \
        protobuf-compiler \
        python-yaml \
        wget


# OpenCV 3.0.0 is needed to support custom allocators for GpuMat objects.
git clone --depth 1 -b 3.0.0 https://github.com/Itseez/opencv.git /opencv && \
    cd /opencv && \
    cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON \
          -DWITH_CUDA=ON -DCUDA_ARCH_BIN="${CUDA_ARCH}" -DCUDA_ARCH_PTX="${CUDA_ARCH}" \
          -DWITH_JPEG=ON -DBUILD_JPEG=ON -DWITH_PNG=ON -DBUILD_PNG=ON \
          -DBUILD_TESTS=OFF -DBUILD_EXAMPLES=OFF -DWITH_FFMPEG=OFF -DWITH_GTK=OFF \
          -DWITH_OPENCL=OFF -DWITH_QT=OFF -DWITH_V4L=OFF -DWITH_JASPER=OFF \
          -DWITH_1394=OFF -DWITH_TIFF=OFF -DWITH_OPENEXR=OFF -DWITH_IPP=OFF -DWITH_WEBP=OFF \
          -DBUILD_opencv_superres=OFF -DBUILD_opencv_java=OFF -DBUILD_opencv_python2=OFF \
          -DBUILD_opencv_videostab=OFF -DBUILD_opencv_apps=OFF -DBUILD_opencv_flann=OFF \
          -DBUILD_opencv_ml=OFF -DBUILD_opencv_photo=OFF -DBUILD_opencv_shape=OFF \
          -DBUILD_opencv_cudabgsegm=OFF -DBUILD_opencv_cudaoptflow=OFF -DBUILD_opencv_cudalegacy=OFF \
          -DCUDA_NVCC_FLAGS="--default-stream per-thread -O3" -DCUDA_FAST_MATH=ON && \
    make -j"$(nproc)" install && \
	make clean

# A modified version of Caffe is used to properly handle multithreading and CUDA streams.
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

# Download Caffenet
/caffe/scripts/download_model_binary.py /caffe/models/bvlc_reference_caffenet && \
    /caffe/data/ilsvrc12/get_ilsvrc_aux.sh

echo "/usr/local/lib" >> /etc/ld.so.conf && \
    ldconfig

# Install golang
export GOLANG_VERSION=1.6
wget -O - https://storage.googleapis.com/golang/go${GOLANG_VERSION}.linux-amd64.tar.gz \
    | tar -v -C /usr/local -xz
export GOPATH=/home/ubuntu/gopath
export PATH=$GOPATH/bin:/usr/local/go/bin:$PATH

# Build inference server
#COPY inference /go/src/inference
#COPY common.h /go/src/common.h
go get -ldflags="-s" inference

#CMD ["inference", \
     #"/caffe/models/bvlc_reference_caffenet/deploy.prototxt", \
     #"/caffe/models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel", \
     #"/caffe/data/ilsvrc12/imagenet_mean.binaryproto", \
     #"/caffe/data/ilsvrc12/synset_words.txt"]
