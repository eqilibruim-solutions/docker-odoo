#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${DB_FILTER}
: ${WORKERS}
: ${MAXCRONTHREADS}
: ${DATABASE}
: ${LIMIT_MEMORY_HARD}
: ${LIMIT_MEMORY_SOFT}
: ${LIMIT_REQUEST}
: ${LIMIT_TIME_CPU}
: ${LIMIT_TIME_REAL}
: ${XMLRPC_PORT}
: ${LONGPOLLING_PORT}
: ${LOAD}

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"
check_param "db_host" "$HOST"
check_param "db_port" "$PORT"
check_param "db_user" "$USER"
check_param "db_password" "$PASSWORD"
check_param "db-filter" "$DB_FILTER"
check_param "workers" "$WORKERS"
check_param "max-cron-threads" "$MAXCRONTHREADS"
check_param "database" "$DATABASE"
check_param "limit-memory-hard" "$LIMIT_MEMORY_HARD"
check_param "limit-memory-soft" "$LIMIT_MEMORY_SOFT"
check_param "limit-request" "$LIMIT_REQUEST"
check_param "limit-time-cpu" "$LIMIT_TIME_CPU"
check_param "limit-time-real" "$LIMIT_TIME_REAL"
check_param "xmlrpc-port" "$XMLRPC_PORT"
check_param "longpolling-port" "$LONGPOLLING_PORT"
check_param "load" "$LOAD"



case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
