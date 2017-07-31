#!/bin/bash - 
#===============================================================================
#
#          FILE: help.sh
# 
#         USAGE: ./help.sh 
# 
#   DESCRIPTION: Show help message
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: TRANG TRAN 
#  ORGANIZATION: 
#       CREATED: 07/29/2017 09:28
#      REVISION:  ---
#===============================================================================

set -o nounset                              # Treat unset variables as an error
# shellcheck source=./helpers.sh
. "$SOURCE_DIR/helpers.sh"

SOURCE_NAME="${BASH_SOURCE[*]: -1}"

function show_help()
{
    cat << EOF
Usage: $SOURCE_NAME [options]


options:
    -h, --help                          Show this help.
    -f, --file                          Post input values as a file.
    -t, --title string                  Title of the post.
    
EOF
}



#-------------------------------------------------------------------------------
# Parse argument
#-------------------------------------------------------------------------------

function parse_args()
{

    while [[ $# -gt 0 ]] ; do
        opt="$1"
        shift
    
    
        case "$opt" in
            -h|\?|--help)
                show_help
                exit 0
                ;;

            -t|--title)
                title="$1"
                shift
                ;;

            -c| --channel)
                channel="$1"
                shift
                ;;

            -u| --username)
                username="$1"
                shift
                ;; 

            -i| --icon)
                icon="$1"
                shift
                ;;

            --setup)
                setup
                exit 0
                ;;

            *)
                tmp=$(show_help)
                err_exit 1 "Illegal option $opt" $'\n\n'"$tmp"
                ;;

        esac    # --- end of case ---
    done
}


#-------------------------------------------------------------------------------
# Setup configuration file
#-------------------------------------------------------------------------------

function setup()
{
    # check whether $HOME exists
    if [[ -z "$HOME" ]]; then
        err_exit 1 "\$HOME is not defined. Please set it first"
    fi

    # check whether curl is installed
    if [[ -z $(command -v curl) ]] ; then
        read -rp "curl is not installed, do you want to install it? [y/n] " choice
        case "$choice" in
            y|Y|yes|YES )
                if [[ -z $(command -v brew) ]]; then
                    brew install curl
                    result="$?"
                else
                    err_exit 1 "Don't know to install curl, please install it first"
                fi
                ;;
            * )
                err_exit 0 "Aborting"
                ;;
        esac
        if [[ "$result" == "0" ]]; then
            echo "curl installed successfully."
        fi
    fi

    # check local config file
    local_conf="$HOME/.myslacktee"
    if [[ -e "$local_conf" ]]; then
        echo ".slacktee is found in your home directory"
        read -rp "Are you sure to overwrite it? [y/n] " choice
        case "$choice" in
            y|Y )
                ;;
            *)
                err_exit 0 "Aborting"
                ;;
        esac
    fi


    # Start setup
    read -rp "Incoming Webhook URL [$webhook_url]: " input_webhook_url
    echo "$input_webhook_url"
    if [[ -z "$input_webhook_url" ]]; then
        input_webhook_url="$webhook_url"
    fi

    read -rp "username [$username]: " input_username 
    if [[ -z "$input_username" ]] ; then
        input_username="$username"
    fi

   read -rp "channel [$channel]: " input_channel
   if [[ -z "$input_channel" ]]; then
       input_channel="$channel"
   fi 

    read -rp "icon [$icon]: " input_icon
    if [[ -z "$input_icon" ]]; then
        input_icon="$icon"
    fi

    # write to configuration file
    cat << EOF | sed 's/^[[:space:]]*//' > "$local_conf"
webhook_url="$input_webhook_url"
username="$input_username"
channel="$input_channel"
icon="$input_icon"
EOF
    
}


#-------------------------------------------------------------------------------
# Read in our configuration
#-------------------------------------------------------------------------------


function setup_environment()
{
    # reading raw configuration first
    if [[ -e "/etc/myslacktee.conf" ]]; then
        # shellcheck disable=SC1091
        . /etc/myslacktee.conf
    fi

    if [[ -n "$HOME" && -e "$HOME/.myslacktee"  ]]; then
        # shellcheck disable=SC1091,SC1090
        . "$HOME/.myslacktee"
    fi
}



#-------------------------------------------------------------------------------
# Check configuration. Sanitize constants.
#-------------------------------------------------------------------------------
function check_configuration(){
    if [[ -z $(command -v curl) ]]; then
        err_exit 1 "curl is not installed. Please install it first."
    fi

    if [[ -z ${webhook_url} ]]; then
        err_exit 1 "Please run again with --setup to setup."
    fi

    if [[ -z ${channel} ]]; then
        err_exit 1 "Please run again with --setup to setup."
    fi

    if [[ -z "${icon}" ]]; then
        err_exit 1 "Please run again with --setup to setup."
    else
        icon=${icon#:} # remove leading ':'
        icon=${icon%:} # remove trailing '%'
    fi
}



#-------------------------------------------------------------------------------
# Send message
#-------------------------------------------------------------------------------

function send_message()
{
    message="$1"
    data="{\"channel\": \"$channel\", \
        \"icon_emoji\": \":${icon}:\", \
        \"username\": \"$username\",
        \"text\": \"$message\"}"

    echo "$data"

    curl -X POST -H 'Content-type: application/json' \
        --data "$data" "$webhook_url"
}


function process_line()
{
    text="${text:-""}\n$1"
}



