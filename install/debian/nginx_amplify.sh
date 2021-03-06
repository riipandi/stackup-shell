#!/bin/bash
if [[ $EUID -ne 0 ]]; then echo 'This script must be run as root' ; exit 1 ; fi

# Determine root directory
[ -z $ROOTDIR ] && PWD=$(dirname `dirname $(dirname $(readlink -f $0))`) || PWD=$ROOTDIR

# Common global variables
source "$PWD/common.sh"

#-----------------------------------------------------------------------------------------
msgSuccess "\n--- Installing Nginx Amplify"
#-----------------------------------------------------------------------------------------

# if [ -f "$PWD/config/stackup.ini" ]; then
#     [[ $(cat "$PWD/config/stackup.ini" | grep -c "amplify_install") -eq 1 ]] && amplify_install=$(crudini --get $PWD/config/stackup.ini '' 'amplify_install')
#     [[ -z "$amplify_install" ]] && read -ep "Do you want to use Nginx Amplify?           y/n : " amplify_install
# fi

if [[ "${amplify_install,,}" =~ ^(yes|y)$ ]] ; then
    if [ -f "$PWD/config/stackup.ini" ]; then
        [[ $(cat "$PWD/config/stackup.ini" | grep -c "amplify_key") -eq 1 ]] && amplify_key=$(crudini --get $PWD/config/stackup.ini '' 'amplify_key')
        [[ -z "$amplify_key" ]] && read -ep "Nginx Amplify Key                               : " amplify_key
    fi

    # Install and configure Nginx Amplify
    API_KEY=$amplify_key bash <(curl -sLo- https://git.io/fNWVx)
    DB_ROOT_USER=`crudini --get /etc/mysql/conf.d/mysql.cnf mysql user`
    DB_ROOT_PASS=`crudini --get /etc/mysql/conf.d/mysql.cnf mysql password`
    DB_SOCKET_PATH="/var/run/mysqld/mysqld.sock"

    crudini --set /etc/amplify-agent/agent.conf 'listener_syslog-default' '​address' '127.0.0.1:13579'
    crudini --set /etc/amplify-agent/agent.conf 'credentials' 'hostname' `hostname -f`
    crudini --set /etc/amplify-agent/agent.conf 'extensions' 'phpfpm' 'True'
    crudini --set /etc/amplify-agent/agent.conf 'extensions' 'mysql'  'True'
    crudini --set /etc/amplify-agent/agent.conf 'mysql' 'unix_socket' $DB_SOCKET_PATH
    crudini --set /etc/amplify-agent/agent.conf 'mysql' 'password'    $DB_ROOT_PASS
    crudini --set /etc/amplify-agent/agent.conf 'mysql' 'user'        $DB_ROOT_USER
    systemctl restart amplify-agent
fi
