# Source library 

PRJ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
UTILS_DIR="${PRJ_DIR}/utils"
TFS_PATH="${PRJ_DIR}/terraform/aws"
export EXAMPLE="streaming-pacman"

LOG_NAME="${EXAMPLE}_stop.log"


function end_demo {
  
    # Source library
    source $UTILS_DIR/demo_helper.sh 

    # Destroy Confluent Cloud resources
    if [ -z "$1" ]; then
        echo "ERROR: Must supply argument that is the client configuration file created from './start.sh'. (Is it in stack-configs/ folder?) "
        exit 1
    else
        DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
        CONFIG_FILE=$PRJ_DIR/$1
        ccloud::ccloud_stack_destroy $CONFIG_FILE
    fi

    echo "Removing folder: $PRJ_DIR/delta_configs"
    rm -r $PRJ_DIR/delta_configs

    # Destroy Demo Infrastructure using Terraform
    cd $TFS_PATH
    terraform destroy --auto-approve

    #rm -f "${TFS_PATH}/config.auto.tfvars"
    
    #rm -f "${TMP_FOLDER}/cluster_1.client.config"
    #rm -f "${TMP_FOLDER}/cluster_2.client.config"
    #rm -f "${TMP_FOLDER}/cluster_3.client.config"

}

end_demo $1 2>&1 | tee -a $LOG_NAME