#!/bin/bash


# Environment settings
path=$(pwd)
thresholdGB="1"
sleepDuration="15s"
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


while true; do

   # run diagnostics command #
   $diagnosticsCommand
   diagnostics_status=$?

   if [ "$diagnostics_status" -eq 1 ]; then

      # mount primary storage #
      sudo mount $devicePrimaryStorage $filepathPrimary

      # backup procedure <
      deviceSize=$(du -sBG $filepathPrimary | awk '{print $1}' | sed 's/G//')

      if [ "$deviceSize" -gt "$thresholdGB" ]; then

         if [ -n "$deviceSecondaryStorage" ]; then

            sudo mount $deviceSecondaryStorage $filepathSecondary
            sudo rsync -av "$filepathPrimary/" "$filepathSecondary/"
            sudo umount $deviceSecondaryStorage

         fi

         sudo rm -rf $filepathPrimary/*

      fi

      # >

      # iterate (videos) <
      for deviceVideo in "${deviceVideos[@]}"; do

         echo $deviceVideo

         # mkdir if DNE
         # record source in background
         # sudo mkdir -p "${filepathPrimary}/${deviceVideo}"
         # (
         #    localFile="$(date +%Y%m%d-%H%M)${videoFormat}"
         #    sudo ffmpeg -y \
         #       -f v4l2 \
         #       -i "../../${deviceVideo}" \
         #       -c:v libx264 \
         #       -preset ultrafast \
         #       -t $recordDuration \
         #       "${filepathPrimary}/${deviceVideo}/${localFile}"
         # ) &

      done

      # >

      # complete all tasks #
      wait

   elif [ "$diagnostics_status" -eq 0 ]; then

      # unmount primary storage #
      sudo umount $devicePrimaryStorage

      echo "POWER EFFICIENT MODE"
      sleep $sleepDuration

   fi

done