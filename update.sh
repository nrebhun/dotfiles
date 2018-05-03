#!/bin/bash

ALL_COMPONENTS=("aliases" "env_vars" "functions" )

function update_component() {
    components=("$@")
    for component in "${components[@]}"; do
        echo "Updating $component"
        cp ./.$component ~/.$component
    done
}

if [ -z "$1" ]; then
    echo "No argument supplied. Try again."
else
    COMPONENTS_TO_UPDATE=$@
    if [ $@ == "all" ]; then
        COMPONENTS_TO_UPDATE=( "${ALL_COMPONENTS[@]}" )
    fi
    
    update_component "${COMPONENTS_TO_UPDATE[@]}"
    echo "Configuration updated! Please reload!"
fi

