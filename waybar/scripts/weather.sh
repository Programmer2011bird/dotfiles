#!/bin/bash
weather=$(curl -s 'ir.wttr.in/Yazd+Ardakan?format=%l:+%t+%c+%C')
# Add a weather icon based on condition
icon=""  # Default wind icon
[[ "$weather" == *"Sunny"* ]] && icon=""
[[ "$weather" == *"Rain"* ]] && icon=""
[[ "$weather" == *"Cloud"* ]] && icon=""

printf '{"text": " %s %s", "tooltip": "%s "}\n' "$icon" "$weather" "$weather"
