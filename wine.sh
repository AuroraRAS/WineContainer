#!/bin/bash

run_param=""
wine_param=""

run_param="\
        --env WINEPREFIX=/root/wine \
	--entrypoint wine \
"

for param in $@; do
	if [ $param = "--flush" ]; then
		podman pull fedora:latest && \
		podman build --no-cache -t winefedora -f ContainerfileWineBase
		exit 0
	elif [ $param = "--upgrade" ]; then
		podman build --no-cache -t winefedora .
		podman image prune
		exit 0
	fi
	
	if [ $param = "-32" ]; then
		run_param="\
		        --env WINEARCH=win32 \
		        --env WINEPREFIX=/root/wine32 \
		        --entrypoint wine32 \
		"
	elif [ $param = "-d" ]; then
		wine_param="explorer /desktop=shell,1280x720 explorer "
	elif [ $param = "-hostnet" ]; then
		run_param="${run_param} --net host "
	elif [ $param = "-zhcn" ]; then
		run_param="${run_param} \
			--env LANG=zh_CN.UTF-8 \
			--env LANGUAGE=zh_CN:zh \
			--env LC_CTYPE="zh_CN.UTF-8" \
			--env LC_NUMERIC="zh_CN.UTF-8" \
			--env LC_TIME="zh_CN.UTF-8" \
			--env LC_COLLATE="zh_CN.UTF-8" \
			--env LC_MONETARY="zh_CN.UTF-8" \
			--env LC_MESSAGES="zh_CN.UTF-8" \
			--env LC_PAPER="zh_CN.UTF-8" \
			--env LC_NAME="zh_CN.UTF-8" \
			--env LC_ADDRESS="zh_CN.UTF-8" \
			--env LC_TELEPHONE="zh_CN.UTF-8" \
			--env LC_MEASUREMENT="zh_CN.UTF-8" \
			--env LC_IDENTIFICATION="zh_CN.UTF-8" \
			--env LC_ALL="zh_CN.UTF-8 "
		"
	elif [ $param = "-debug" ]; then
		run_param="${run_param} --cap-add=SYS_PTRACE "
        elif [ $param = "-cpu1" ]; then
                run_param="${run_param} --cpus=1 "
	elif [ $param = "-v" ]; then
		podman run -it --rm --entrypoint "/bin/bash" "winefedora" "dnf"
		exit 0
	elif [ $param != "-"* ]; then
		wine_param=${param}
	fi
done

#	--env LANG=zh_CN.UTF-8 \
#	--net "host" \

podman run -i -t --rm \
	--security-opt label=disable \
	--device "/dev/dri" \
	--device "/dev/snd" \
	--volume "/tmp/.X11-unix/X0:/tmp/.X11-unix/X0" \
	--volume "$HOME/wine/root:/root" \
	--volume "$HOME/wine/d:/mnt/d" \
	--volume "$HOME/.steam/steam/steamapps/common:/mnt/d/Steam/steamapps/common" \
	--env DISPLAY=unix$DISPLAY \
	$run_param \
	"winefedora" $wine_param

