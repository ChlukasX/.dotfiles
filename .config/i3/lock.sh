#!/bin/sh

# Lower the screen brightness
#brightnessctl s 1

# Define the new color palette
BLANK='#00000000'
DEFAULT='#1F1F28'
TEXT='#DCD7BA'
RING='#363646'
WRONG='#E46876'
VERIFYING='#7FB4CA'

i3lock \
--insidever-color=$BLANK        \
--ringver-color=$VERIFYING      \
\
--insidewrong-color=$BLANK      \
--ringwrong-color=$WRONG        \
\
--inside-color=$BLANK           \
--ring-color=$RING              \
--line-color=$BLANK             \
--separator-color=$DEFAULT      \
\
--verif-color=$TEXT             \
--wrong-color=$TEXT             \
--time-color=$TEXT              \
--date-color=$TEXT              \
--layout-color=$TEXT            \
--keyhl-color=$WRONG            \
--bshl-color=$WRONG             \
\
--screen 1                      \
--blur 5                        \
--clock                         \
--indicator                     \
--time-str="%H:%M"           \
--date-str="%d-%m-%Y"           \
--keylayout 1
             \
