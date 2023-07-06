#!/bin/bash

while IFS= read -r line; do
  # Extract the floating-point number using grep and awk
  number=$(echo "$line" | grep -oE '[0-9]+\.[0-9]+e[+-]+[0-9]+')
  
  # Convert the number to megabytes
  converted=$(awk "BEGIN { printf \"%.2f\", $number / (1024 * 1024) }")
  
  # Echo the converted value
  echo "$converted"
done
