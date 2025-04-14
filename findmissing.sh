#!/bin/bash
#### Check which idx between start_idx and end_idx is missing by reading logs in the input file

# Check if required arguments are provided
if [ $# -ne 3 ]; then
  echo "Usage: $0 input_file start_idx end_idx"
  exit 1
fi

input_file="$1"
start_idx="$2"
end_idx="$3"

# Check if input file exists
if [ ! -f "$input_file" ]; then
  echo "Error: File '$input_file' not found!"
  exit 1
fi

# Check if start_idx and end_idx are valid numbers
if ! [[ "$start_idx" =~ ^[0-9]+$ ]] || ! [[ "$end_idx" =~ ^[0-9]+$ ]]; then
  echo "Error: start_idx and end_idx must be positive integers!"
  exit 1
fi

# Check if start_idx <= end_idx
if [ "$start_idx" -gt "$end_idx" ]; then
  echo "Error: start_idx must be less than or equal to end_idx!"
  exit 1
fi

# Loop through each number in the range
for num in $(seq "$start_idx" "$end_idx"); do
  # Check if the number exists in the file
  if ! grep -q "\b${num}" "$input_file"; then
    echo "$num"
  fi
done