#!/usr/bin/env bash
. ./colors.sh
. ./formats.sh
. ./get_system_info.sh

echo "System and version identified: $OS ($VER)"

case "$OS" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=macOS;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${OS}"
esac

BEGIN_MSG="Setting up your ${machine}...";
SUCCESS_MSG=$"Huzzah! Your ${GREEN}${machine}${CF} machine should be all set! 🚀";
UNSUPPORTED_MSG=$"Sorry, setup for ${BOLD}${machine}${CF}${RED} machines is not currently supported.";

case "${machine}" in
    # Linux)      echo "$BEGIN_MSG";        # coming soon!
    #             echo "$SUCCESS_MSG";;

    macOS)      printf "$BEGIN_MSG";
                ./macOS_setup.sh;
                printf "$SUCCESS_MSG";;

    *)          printf "${RED}${UNSUPPORTED_MSG}${CF}";;
esac
