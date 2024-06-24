#!/bin/bash

# This script is used to automatically generate the config file for hwpc-sensor based on the CPU model.

get_events() {
    events_file="cpu_events.json"

    logs=$(hwpc-sensor 2>&1)
    logs=${logs,,}
    cpu_model=$(echo "$logs" | tr '[:upper:]' '[:lower:]')
    events=$(cat "$events_file")
    if [[ $events == *"$cpu_model"* ]]; then
        echo "$events" | awk -v model="$cpu_model" 'BEGIN{RS="]"} $0~model {print "[" substr($0, index($0, "[")+1) "]"; exit}'
    else
        exit -1
    fi
}

events_to_json() {
    local events=$@
    echo $events | tr -d '\n' | tr -d ' ' | awk -v RS="," 'BEGIN{print "    \"container\": {\n        \"core\": {\n            \"events\": ["} {if (NR > 1) printf ","; printf "\n                \"" $0 "\""} END { printf "\n            ]\n        }\n    }\n"}'
}

update_config_file() {
    events=$(get_events)
    config_file=$1

    # Create a backup of the config file
    cp "$config_file" "$config_file.bak"

    # Remove the last } from the config file
    sed -i '$ d' "$config_file.bak"

    # Replace the last } with }, in the config file
    sed -i '$ s/$/,/' "$config_file.bak"

    # Add the events to the config file
    events_to_json "$events" >>"$config_file.bak"

    # Add the last } to the config file
    echo "}" >>"$config_file.bak"

}

get_events
# update_config_file $1
# hwpc-sensor --config-file $1.bak
