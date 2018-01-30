#!/bin/bash

ALL_COMPONENTS=("aliases" "env_vars" "functions" )

function update_component() {
    for component in $@; do
        echo "Updating $component"
        cp ./.$component ~/.$component
    done
}

if [ -z "$1" ]; then
    echo "No argument supplied. Try again."
else
    update_component $@
    echo "Configuration updated! Please reload!"
fi

