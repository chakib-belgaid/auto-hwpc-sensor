#!/bin/bash

# This script is used to update the configuration file for the hwpc-sensor tool.
# It retrieves the CPU information and corresponding events from a JSON file,
# and then updates the configuration file with the retrieved events.

# Function to get the CPU information by analyzing the logs from hwpc-sensor
# Arguments: None
# Returns: The CPU information
get_cpu() {
    events_file="cpu_events.json"
    logs=$(hwpc-sensor 2>&1 | tr '[:upper:]' '[:lower:]')
    cpu_candidates=$(grep -oP '"\K[^"]*(?=":)' $events_file)

    while read -r candidate; do
        if echo "$logs" | grep -q "$candidate"; then
            echo "$candidate"
            exit 0
        fi
    done <<<"$cpu_candidates"
    exit 1
}

# Function to get events for a specific CPU
# Parameters:
#   $1: The CPU model
# Returns:
#   The events for the specified CPU
#   Exits with -1 if the CPU model is not found in the events file
get_events() {

    cpu=$1
    events_file="cpu_events.json"
    events=$(cat "$events_file")
    if [[ $events == *"$cpu"* ]]; then
        echo "$events" | awk -v model="$cpu" 'BEGIN{RS="]"} $0~model {print "[" substr($0, index($0, "[")+1) "]"; exit}'
    else

        exit -1
    fi
}

update_config_file() {
    cpu=$(get_cpu)
    if [ $? -eq 1 ]; then
        echo "Error: cpu not found in the events file. Exiting."
        # Handle the error, for example, exit the script or try a fallback operation
        exit 1
    else
        echo "CPU model found : $cpu"
    fi
    events=$(get_events $cpu)
    config_file=$1

    cp "$config_file" "$config_file.updated"
    sed -i '$ d' "$config_file.updated"
    sed -i '$ s/$/,/' "$config_file.updated"

    echo '    "container": {' >>"$config_file.updated"
    echo '        "core": {' >>"$config_file.updated"
    echo '            "events": ' >>"$config_file.updated"
    for event in $events; do
        echo '                '$event >>"$config_file.updated"
    done
    echo '        }' >>"$config_file.updated"
    echo '    }' >>"$config_file.updated"
    echo "}" >>"$config_file.updated"
}

if [ ! -f "cpu_events.json" ]; then
    echo "Warning: cpu_events.json file not found. Downloading the file from the repository."

    curl -O https://raw.githubusercontent.com/chakib-belgaid/auto-hwpc-sensor/main/cpu_events.json >cpu_events.json
fi

update_config_file $1
hwpc-sensor --config-file $config_file.updated
