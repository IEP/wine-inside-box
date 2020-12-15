#!/usr/bin/env bash
sleep 1s

Xvfb :99 &
export DISPLAY=:99

exec "$@"