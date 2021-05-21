#!/bin/bash
#set -e # Exit if any error occurs
#set -x # Print execution process
#set -u # Warn undefined variable


function help_msg() {
    if [ "$1" = "-h" ]; then
        cat <<EOF
        Usages of $2:
            msg $3
            msg $4
EOF
    fi

    
}

function msg() {
    if [ "$1" = "-h" ]; then
cat << EOF
Usages of msg:
    $ msg "log info..."
    $ msg "hello" "world"
EOF
    else
        echo "MSG:$(date): $*" # color todo
    fi    
}

function msg:doc() {
cat <<EOF
Usages of msg:
  $ msg: "log info..."
  $ msg: "hello" "world"
EOF
}


function batch_extensions () {
    if [ "$1" = "-h" ]; then
cat << 'EOF'
Usages of batch_extensions:
    $1: The path where you want to change the extensions.
    $2: The extension what you want to change to.
    Example: batch_extensions ~/test sh
EOF
    else
        for file in `ls $1/*`
        do
            mv $file $file.$2
        done
    fi    

}