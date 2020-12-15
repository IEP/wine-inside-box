#!/usr/bin/env bash
sleep 1s

Xvfb :99 &
export DISPLAY=:99

sleep 1s

wine /root/AHK.exe /S