#!/bin/sh

username="username"
password="password"

google="http://74.125.236.208"
wget_opts="--no-check-certificate -t3 -T3 -qO-"

trap logout SIGHUP SIGINT SIGQUIT SIGTERM

login() {
    fgt_redirect=$(
        wget ${wget_opts} --max-redirect=0 -S ${google} 2>&1 >/dev/null
    )
    if [ -z "${fgt_redirect}" ];
    then
        state="fail"
    elif [ -z "$(echo ${fgt_redirect} | grep "HTTP\/1.1 303 See Other")" ];
    then
        state="login"
    else
        fgt_auth_url=$(
            echo "${fgt_redirect}" |
            sed -n -e 's/.*Location: \(.*\).*/\1/p'
        )
        fgt_auth_resp=$(
            wget ${wget_opts} ${fgt_auth_url}
        )
        fgt_auth_magic=$(
            echo "${fgt_auth_resp}" |
            sed -n -e 's/.*NAME="magic" \+VALUE="\([^"]\+\).*/\1/p'
        )
        fgt_post_resp=$(
            wget ${wget_opts} --post-data \
                "username=${username}&password=${password}&magic=${fgt_auth_magic}&4Tredir=/" \
                "${fgt_auth_url}"
        )
        fgt_keepalive_url=$(
            echo "${fgt_post_resp}" |
            sed -n -e 's/.*location.href="\([^"]\+\).*/\1/p'
        )
        if [ -z "${fgt_keepalive_url}" ];
        then
            state="badauth"
        else
            logger -t firewall-auth "Logged in"
            fgt_logout_url=$(
                echo "${fgt_post_resp}" |
                sed -n -e 's/.*<p><a href="\([^"]\+\).*/\1/p'
            )
            state="keepalive"
        fi
    fi
}

keepalive() {
    fgt_keepalive_resp=$(
        wget ${wget_opts} -S ${fgt_keepalive_url} 2>&1 >/dev/null
    )
    if [ -z "$(echo "${fgt_keepalive_resp}" | grep "HTTP\/1.1 200 OK")" ];
    then
        state="retry"
    else
        state="keepalive"
    fi
}

logout() {
    if [ -n "${fgt_logout_url}" ];
    then
        logger -t firewall-auth "Logging out"
        wget ${wget_opts} ${fgt_logout_url} 2>&1 >/dev/null
    fi
    exit
}

login
while :
do
    case ${state} in
        "fail")
            logger -t firewall-auth "Network failure"
            sleep 30 & wait $!
            login
            ;;
        "login")
            logger -t firewall-auth "Already logged in"
            sleep 10 & wait $!
            login
            ;;
        "badauth")
            logger -t firewall-auth "Bad credentials"
            sleep 120 & wait $!
            login
            ;;
        "retry")
            logger -t firewall-auth "Retrying login"
            sleep 1 & wait $!
            login
            ;;
        "keepalive")
            logger -t firewall-auth "Keeping alive"
            sleep 120 & wait $!
            keepalive
            ;;
        *)
            logger -t firewall-auth "Something went wrong"
            sleep 10 & wait $!
            login
            ;;
    esac
done
