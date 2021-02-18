#!/bin/bash
#set -e

PRJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UTILS_DIR="${PRJ_DIR}/utils"
TMP_FOLDER="${PRJ_DIR}/tmp"
TFS_PATH="${PRJ_DIR}/terraform"
STATE_FILE_PATH="${TFS_PATH}/terraform.tfstate"
STACK_FILEPATH="${TMP_FOLDER}/stack.created"
ENV_FILEPATH="${TMP_FOLDER}/envs.created"
export EXAMPLE="streaming-pacman"

LOG_NAME="${EXAMPLE}_start.log"


function start_demo {

    source $UTILS_DIR/demo_helper.sh

    

    ccloud::validate_version_ccloud_cli 1.7.0 \
        && print_pass "ccloud version ok" \
        || exit 1

    ccloud::validate_logged_in_ccloud_cli \
        && print_pass "logged into ccloud CLI" \
        || exit 1

    check_jq \
        && print_pass "jq found" \
        || exit 1

    echo
    echo ====== Create new Confluent Cloud stack
    ccloud::prompt_continue_ccloud_demo || exit 1
    ccloud::create_ccloud_stack true
    SERVICE_ACCOUNT_ID=$(ccloud kafka cluster list -o json | jq -r '.[0].name' | awk -F'-' '{print $4;}')
    if [[ "$SERVICE_ACCOUNT_ID" == "" ]]; then
    echo "ERROR: Could not determine SERVICE_ACCOUNT_ID from 'ccloud kafka cluster list'. Please troubleshoot, destroy stack, and try again to create the stack."
    exit 1
    fi
    CONFIG_FILE=stack-configs/java-service-account-$SERVICE_ACCOUNT_ID.config
    export CONFIG_FILE=$CONFIG_FILE
    ccloud::validate_ccloud_config $CONFIG_FILE \
    && print_pass "$CONFIG_FILE ok" \
    || exit 1

    echo ====== Generate CCloud configurations
    ccloud::generate_configs $CONFIG_FILE

    DELTA_CONFIGS_DIR=delta_configs
    source $DELTA_CONFIGS_DIR/env.delta
    printf "\n"

    # Pre-flight check of Confluent Cloud credentials specified in $CONFIG_FILE
    MAX_WAIT=720
    echo "Waiting up to $MAX_WAIT seconds for Confluent Cloud ksqlDB cluster to be UP"
    retry $MAX_WAIT ccloud::validate_ccloud_ksqldb_endpoint_ready $KSQLDB_ENDPOINT || exit 1
    ccloud::validate_ccloud_stack_up $CLOUD_KEY $CONFIG_FILE || exit 1

    # Set Kafka cluster
    ccloud::set_kafka_cluster_use_from_api_key $CLOUD_KEY || exit 1

    #################################################################
    # Confluent Cloud ksqlDB application
    #################################################################
    ./create_ksqldb_app.sh || exit 1


    printf "\nDONE! Connect to your Confluent Cloud UI at https://confluent.cloud/\n"
    echo
    echo "Local client configuration file written to $CONFIG_FILE"
    echo
    echo "Cloud resources are provisioned and accruing charges. To destroy this demo and associated resources run ->"
    echo "    ./stop.sh $CONFIG_FILE"
    echo
    


}


start_demo 2>&1 | tee -a $LOG_NAME