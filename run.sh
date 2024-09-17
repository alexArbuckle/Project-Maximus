#!/bin/bash


# environment <
path=$(pwd)
thresholdGB="1"
sleepDuration=3
videoFormat=".mov"
recordDuration=180

devicePrimaryStorage="/dev/sda1"
filepathPrimary="${path}/primary"
deviceSecondaryStorage="/dev/sdb1"
filepathSecondary="${path}/secondary"
deviceVideos=("dev/video0" "dev/video2")

pinIsCharging=17
pinLowVoltage=27
diagnosticsCommand="sudo python3 ${path}/diagnostics.py ${pinIsCharging} ${pinLowVoltage}"

# >


while true; do

   # while (running) <
   if [ "${diagnosticsCommand}" = "True" ]; then

      # mount primary #
      sudo mount $devicePrimaryStorage $filepathPrimary

      deviceSize=$(du -sBG $filepathPrimary | awk '{print $1}' | sed 's/G//');

      # backup procedure <
      if [ "$deviceSize" -gt "$thresholdGB" ]; then

         if [ -n "$deviceSecondaryStorage" ]; then

            sudo mount $deviceSecondaryStorage $filepathSecondary;
            sudo rsync -av "$filepathPrimary/" "$filepathSecondary/"
            sudo umount $deviceSecondaryStorage;

         fi

         sudo rm -rf $filepathPrimary/*

      fi

      # >

      # iterate videos <
      for deviceVideo in "${deviceVideos[@]}"; do

         echo $deviceVideo

         # # mkdir if DNE <
         # # record source in background <
         # sudo mkdir -p "${filepathPrimary}/${deviceVideo}";
         # (

         #    localFile="$(date +%Y%m%d-%H%M)${videoFormat}";
         #    sudo ffmpeg -y \
         #       -f v4l2 \
         #       -i "../../${deviceVideo}" \
         #       -c:v libx264 \
         #       -preset ultrafast \
         #       -t $recordDuration \
         #       "${filepathPrimary}/${deviceVideo}/${localFile}"

         # ) &

         # # >

      done

      # >

      # complete all tasks #
      wait

   # >

   else

      # unmount primary #
      sudo umount $devicePrimaryStorage

      echo "POWER SAVING MODE"
      sleep $sleepDuration

   fi

done