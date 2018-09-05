# docker-ffmpeg-nvenc-centos6
It builds ffmpeg with NVEnc (hardware acceraration for video encoding using NVIDIA video cards),
 so you can easily build video encoding environment.


## History

Since [nvidia-docker2](https://github.com/NVIDIA/nvidia-docker) (even nvidia-docker) 
does not support Docker 1.7 runs under CentOS 6, I wrote nealiy equivalent 
Dockerfile and compose file by myself.

## Tested enviionment

> Hardware
>> HP Proliant MicroServer N54L
>> NVIDIA Geforce GT 730
> OS
>> CentOS Linux release 6.10 (Core)
>> Linux 2.6.32-754.3.5.el6.x86_64
> Docker
>> version 1.7.1, build 786b29d
 
## Prerequisites

- NVIDIA video card since Kepler family (at least GeForce GT 710/630) on your linux box
-- see https://developer.nvidia.com/video-encode-decode-gpu-support-matrix
- `kmod-nvidia` NVIDIA video card driver is installed from EPEL repository

```
# You have to below only if you have never used EPEL repository
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-6-8.el6.elrepo.noarch.rpm 
yum update

# install NVIDIA video driver
yum install kmod-nvidia

# uncomment 2 lines in `/etc/modprobe.d/nvidia.conf` 
# so `/dev/nvidia-uvm` is created on every boot
vi /etc/modprobe.d/nvidia.conf

reboot
```

After reboot, ensure all drivers are loaded correctly.


```
$ lsmod | grep nvidia
nvidia_uvm            727407  0
nvidia              14360916  1 nvidia_uvm
ipmi_msghandler        40332  1 nvidia
i2c_core               29164  2 i2c_piix4,nvidia
nvidia_drm              1150  0

```

## Lisense agreement 

This Dockerfile build on the top of `nvidia/cuda` Docker image publicly avilable on Docker Hub.

https://hub.docker.com/r/nvidia/cuda/

`nvidia/cuda` Docker image includes `CUDA Toolkit` that requires lisense agreement
if you use this image in this repository.

## Install ans Usage

```sh
git clone https://github.com/yanbe/docker-ffmpeg-nvenc-centos6 venc
cd venc
# edit docker-compose.yml so configure your video storage directory
vi docker-compose.yml
```

### in docker-compose.yml
```
  volumes:
    - /usr/lib64/nvidia:/usr/local/nvidia/lib64
    - /path/to/your/videos:/var/lib/videos # edit here
```                                                    

```
# build (it takes about 30 min)
docker-compose build

# run
# working directory is docker-compose.yml so you don't need to write full path
docker-compose run --rm ffmpeg ffmpeg -i input.m2ts -c:v h264_nvenc output.mp4

```

And you will see hardware accelarated video encoding in the docker!

```
ffmpeg version N-91790-g23fe072 Copyright (c) 2000-2018 the FFmpeg developers
  built with gcc 5.4.0 (Ubuntu 5.4.0-6ubuntu1~16.04.10) 20160609
  configuration: --enable-cuda --enable-cuvid --enable-nvenc --enable-nonfree --enable-libnpp --extra-cflags=-I/usr/local/cuda/include
  libavutil      56. 19.100 / 56. 19.100
  libavcodec     58. 27.101 / 58. 27.101
  libavformat    58. 17.106 / 58. 17.106
  libavdevice    58.  4.101 / 58.  4.101
  libavfilter     7. 26.100 /  7. 26.100
  libswscale      5.  2.100 /  5.  2.100
  libswresample   3.  2.100 /  3.  2.100
(snip)
Output #0, mp4, to 'output.mp4':
  Metadata:
    encoder         : Lavf58.17.106
    Stream #0:0: Video: h264 (h264_nvenc) (Main) (avc1 / 0x31637661), yuv420p, 1440x1080 [SAR 4:3 DAR 16:9], q=-1--1, 2000 kb/s, 29.97 fps, 30k tbn, 29.97 tbc
    Metadata:
      encoder         : Lavc58.27.101 h264_nvenc
    Side data:
      cpb: bitrate max/min/avg: 0/0/2000000 buffer size: 4000000 vbv_delay: -1
    Stream #0:1: Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 128 kb/s
    Metadata:
      encoder         : Lavc58.27.101 aac
frame= 5418 fps=101 q=33.0 Lsize=   45622kB time=00:03:00.74 bitrate=2067.7kbits/s dup=27 drop=0 speed=3.37x

```

## References 

This work is based on the article below. Very thanks!

https://qiita.com/toshitanian/items/8aaca6b867099ebd442d
