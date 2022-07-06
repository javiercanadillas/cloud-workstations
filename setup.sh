#!/usr/bin/env bash
#set -x

GCLOUD_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
PROJECT=${GCLOUD_PROJECT_ID:-"javiercm-main-dev"}
REGION="europe-west1"
NETWORK="main"
SUBNETWORK="main"
CLUSTER_NAME="main-cluster"
CLUSTER_CONF_FILE="cluster.json"
WS_CONFIG_FILE="workstation.json"
WS_CONFIG_NAME="cloudtop-main"
# This name must match the name used to create your developer workstation in 
# ssh.cloud.google.com/workstations
WS_NAME="javiercm-cloudtop"

# Generate a Workstation Cluster configuration
gen_cluster_config() {
  cat <<EOF > cluster.json
{
  "network": "projects/${PROJECT}/global/networks/${NETWORK}",
  "subnetwork": "projects/${PROJECT}/regions/${REGION}/subnetworks/${SUBNETWORK}",
}
EOF
}

# Create a Workstation Cluster configuration
create_cluster() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d "@${CLUSTER_CONF_FILE}" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters?workstation_cluster_id=${CLUSTER_NAME}
}

# Chack a Workstation Cluster configuration creation status
check_cluster() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}
}

# Chack a Workstation Cluster configuration creation status
check_workstation() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstationConfigs/${WS_CONFIG_NAME}
}

# Generate a Workstation configuration
gen_workstation_config() {
  cat <<EOF > "${WS_CONFIG_FILE}"
{
  "idleTimeout": "7200s",
  "host_config": {
    "gce_instance_config": {
      "machine_type": "e2-standard-8",
      "pool_size": 1,
    },
  },
  "persistentDirectories": {
    "mountPath": "/home",
    "gcePd": {
      "sizeGb": 200,
      "fsType": "ext4"
    }
  }
}
EOF
}

# Create a Workstation configuration
create_workstation() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json" \
     -d @"$WS_CONFIG_FILE" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstationConfigs?workstation_config_id=${WS_CONFIG_NAME}
}

list_workstations() {
   curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstations
}

ssh_to_workstation() {
  gcloud alpha workstations start-tcp-tunnel \
    --project=${PROJECT} \
    --region=${REGION} \
    --cluster=${CLUSTER_NAME} \
    ${WS_NAME} 22 \
    --local-host-port=:2222
  echo "You can now connect you ${WS_NAME} with the following command:"
  echo "ssh user@localhost -p 2222"
}

help() {
  echo "Invoke the script using the existing functions as options"
  echo "Example: ./setup.sh list_workstations"
  echo ""
  declare -F | awk '{print $NF}' | sort | grep -E -v "^_"
}

submit_operation() {
   curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
     -H "Content-Type: application/json" \
     -d @"$2" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstationConfigs?workstation_config_id=${WS_CONFIG_NAME}
}

# Bootstrap workstations, from cluster creation to template
bootstrap() {
  gen_cluster_config
  create_cluster
  check_cluster
  gen_workstation_config
  create_workstation
  check_workstation
}

# Check if the function exists (bash specific)
if declare -f "$1" > /dev/null; then
  # call arguments verbatim
  "$@"
else
  # Show a helpful error
  echo "'$1' is not a known function name" >&2
  exit 1
fi

#set +x