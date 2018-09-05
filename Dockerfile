FROM nvidia/cuda:9.2-devel
LABEL maintainer "yanbe <y.yanbe@gmail.com>"

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,video,utility

RUN set -x \
	&& ls -a /tmp \
	&& apt-get -y update \
	&& apt-get -y install \
		git \
		yasm \
		pkgconf \
		unzip \
	\
	# build and install nv-codec-headers for ffmpeg
	&& git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git /tmp/nv-codec-headers \
	&& cd /tmp/nv-codec-headers \
	&& make install \
	\
	# build and install ffmpeg
	&& git clone https://git.ffmpeg.org/ffmpeg.git /tmp/ffmpeg \
	&& cd /tmp/ffmpeg \
	&& echo ${LIBRARY_PATH} >> /etc/ld.so.conf.d/cuda-9-2.conf \
	&& ./configure \
		--enable-cuda \
		--enable-cuvid \
		--enable-nvenc \
		--enable-nonfree \
		--enable-libnpp \
		--extra-cflags=-I/usr/local/cuda/include \
	&& make \
	&& make install \
	\
	&& rm -rf /tmp/ffmpeg /tmp/nvenc-codec-headers

WORKDIR /var/lib/videos
CMD ["ffmpeg"]
