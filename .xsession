#!/bin/sh

MONITOR="HDMI1"
dpi=1

HDMI_STATUS=$(xrandr | grep "${MONITOR} connected")
if [ -n "${HDMI_STATUS}" ]; then
  dpi=192
fi

~/dpi ${dpi}
