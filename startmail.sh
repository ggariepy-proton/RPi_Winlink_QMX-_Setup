card=`aplay -l | grep QMX | gawk 'match($0, /card\s(.):/, num){print(num[1])}'`
now=`date`
cat >~/.asoundrc <<EOF
# Custom .asoundrc file with extra buffering
# Generated $now by ~/Scripts/startmail.sh
pcm.!default {
    type plug
    slave {
        pcm "plughw:$card,0"
        format S24_3LE
        rate 12000
        channels 2
        buffer_size 72000  # 4 seconds at 12000 Hz, 2 channels, 3 bytes/sample
        period_size 1200   # 100ms period (adjust as needed)
    }
}

ctl.!default {
    type hw
    card $card
}

pcm.input {
    type plug
    slave {
        pcm "plughw:$card,0"
	format S24_3LE
        rate 12000
        channels 2
    }
}
EOF


echo $asound

