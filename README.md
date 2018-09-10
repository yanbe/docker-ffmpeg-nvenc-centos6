# docker-ffmpeg-nvenc-centos6

It builds ffmpeg with NVIDIA's NVEnc (hadware acceraration for video encoding on NVIDIA GPUs),
so you can easily get fast and efficient video encoding environment.

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
- `nvidia-kmod` NVIDIA video card driver and `nvidia-modprobe` command is installed from cuda repository
-- If you already installed `kmod-nvidia`,  `yum remove` it first 

## Lisense agreement

This Dockerfile build on the top of `nvidia/cuda` Docker image publicly avilable on Docker Hub.

https://hub.docker.com/r/nvidia/cuda/

`nvidia/cuda` Docker image includes `CUDA Toolkit` that requires lisense agreement
if you use this image in this repository.

## Install and Usage

### `nvidia-kmod` driver installation

```
curl -O http://developer.download.nvidia.com/compute/cuda/repos/rhel6/x86_64/cuda-repo-rhel6-9.2.148-1.x86_64.rpm
rpm -i cuda-repo-rhel6-9.2.148-1.x86_64.rpm
yum install perl dkms  # nvidia-kmod dependency package
yum install nvidia-kmod xorg-x11-drv-nvidia xorg-x11-drv-nvidia-libs
```

### Setup scripts, build docker image and run
```
git clone https://github.com/yanbe/docker-ffmpeg-nvenc-centos6 venc
cd venc
```

On CentOS 6, nvidia-kmod package does not create /dev/nvidia* device files 
automatically. So we have to setup script manually.

ref: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#runfile-verifications

```
cp nvidia-device-files.sh /usr/local/bin

vi /etc/init.d/rc.local
# add following line in /etc/init.d/rc.local:
# 
# /usr/local/bin/nvidia-device-files.sh
reboot
```

After reboot, ensure all drivers are loaded correctly and device files are created.

```
$ lsmod | grep nvidia
nvidia_uvm            727407  0
nvidia              14360916  1 nvidia_uvm
ipmi_msghandler        40332  1 nvidia
i2c_core               29164  2 i2c_piix4,nvidia
nvidia_drm              1150  0

$ ls /dev/nvidia*
/dev/nvidia-uvm /dev/nvidia0 /dev/nvidiactl
```

Edit docker-compose.yml in the `venc` directory to configure your video storage 
directory mounted on docker container.

```
vi docker-compose.yml

# in docker-compose.yml
  volumes:
    - /usr/lib64/nvidia:/usr/local/nvidia/lib64
    - /path/to/your/videos:/var/lib/videos  # edit '/path/to/your/videos'
```

Then build docker image by following command. (it takes about 30 minites)

```
docker-compose build

### Transcode video with NVEnc and NVCUVID enabled ffmpeg in Docker

```
docker-compose run --rm ffmpeg ffmpeg -hwaccel cuvid -c:v mpeg2_cuvid -deint 1 -drop_second_field true -i input.m2ts -c:v h264_nvenc output.mp4
```
Note that working directory is /var/lib/videos equal to your video storage directory
so you don't need to write full path.
(command line options are based on https://trac.ffmpeg.org/wiki/HWAccelIntro )

And you will see hardware accelarated video encoding in the docker!

```
(snip)
Stream mapping:
  Stream #0:0 -> #0:0 (mpeg2video (mpeg2_cuvid) -> h264 (h264_nvenc))
  Stream #0:1 -> #0:1 (aac (native) -> aac (native))
Press [q] to stop, [?] for help
Output #0, mp4, to 'output.mp4':      0kB time=-577014:32:22.77 bitrate=  -0.0kbits/s speed=N/A
  Metadata:
    encoder         : Lavf58.18.100
    Stream #0:0: Video: h264 (h264_nvenc) (Main) (avc1 / 0x31637661), cuda, 960x720 [SAR 4:3 DAR 16:9], q=-1--1, 2000 kb/s, 29.97 fps, 30k tbn, 29.97 tbc
    Metadata:
      encoder         : Lavc58.27.101 h264_nvenc
    Side data:
      cpb: bitrate max/min/avg: 0/0/2000000 buffer size: 4000000 vbv_delay: -1
    Stream #0:1: Audio: aac (LC) (mp4a / 0x6134706D), 48000 Hz, stereo, fltp, 128 kb/s
    Metadata:
      encoder         : Lavc58.27.101 aac
frame=10668 fps=173 q=26.0 size=   93184kB time=00:05:55.85 bitrate=2145.2kbits/s dup=27 drop=0 speed=5.77x
```

Since HP Proliant MicroServer N54L 's CPU is not powerful (AMD Turion II Neo N54L 2.2Ghz dual-core),
Transcoding video from mpeg2 to H264 over 170 fps cannot be achieved without hardware acceralation.

Cheers!

## References

This work is based on the article below. Thanks you very much!

https://qiita.com/toshitanian/items/8aaca6b867099ebd442d
