#!/bin/bash
# startmail.sh
# Written 17-OCT-2025
# Launches ardop and pat winlink
# GPG

function killem() {
  echo "Exiting Pat"
  killall pat
  echo "Exiting ardopcf"
  killall ardopcf
  rm /home/geoff/.asoundrc
  exit 0
}

clear

# Capture script-killing signals so the killem() function
# properly exits everything
trap killem SIGINT EXIT

killall ardopcf

killall pat

killall wsjtx

# Set QMX to USB mode, 3200Hz passband
rigctl -m 2 -t 4532 M USB 3200

# Run the script that generates our custom .asoundrc config file
echo "Creating .asoundrc file"
~/Scripts/email/genasoundrc.sh

# Launch pat winlink client
echo "Starting pat winlink in http mode"
pat http &
echo "Starting ardopcf in hamlib ptt mode"

# Determine which sound card the QMX is assigned to
card=$(aplay -l | grep QMX | gawk 'match($0, /card\s(.):/, num){print(num[1])}')

if [ "$card" = "" ]; then
  echo "Error: Could not determine QMX sound card ID"
  exit 1  
fi
echo "Using sound card ID: $card"

# run ardop using the generated sound card ID 
ardopcf -c RIGCTLD 8515 -o default -i "plughw:$card,0" -G -9999 -H "LOGLEVEL 3;EXTRADELAY 500" &

# Sleep until someone presses CTRL-C
while true
do 
  sleep 1m
done
