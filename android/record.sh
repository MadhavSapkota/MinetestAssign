#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <process_name>"
  exit 1
fi

file="$1.csv"
echo "cpu,mem" > "$file"

# Get the process ID using ps and awk
pid=$(adb shell ps | awk -v pname="$1" '$0 ~ pname {print $2}')

if [ -z "$pid" ]; then
  echo "Error: Process not found. Make sure the process name or command-line argument is correct."
  exit 1
fi

while true; do
  # Run top, grep for the process ID, and use awk to extract CPU and memory values
  res=$(adb shell top -b -n 1 -p "$pid" | grep "$pid" | awk '{print int($9)","int($10)}')

  # Extract CPU and memory values
  cpu=$(echo "$res" | cut -d "," -f1)
  mem=$(echo "$res" | cut -d "," -f2)

  echo "[$(date +"%T")] $pid: $cpu, $mem"
  echo "$cpu,$mem" >> "$file"
  sleep 1
done



