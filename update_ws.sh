# This script changes the mem size of an existing machine to something reasonable (32 Gb)
# If you created the machine with the workstation-plus.json file (64Gb), it scales it back to the workstation.json (32Gb)
PROJECT="javiercm-main-dev"
REGION="europe-west1"
CLUSTER_NAME="main-cluster"
WS_CONFIG_NAME="cloudtop-main"
WS_CONFIG_FILENAME="workstation.json"
PARAMETER="host_config.gce_instance_config.machine_type"
get_workstationConfig() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstationConfigs/${WS_CONFIG_NAME}
}

update_workstationConfig() {
  curl -H "Authorization: Bearer $(gcloud auth print-access-token)" \
    -H "Content-Type: application/json" \
    -d @"$WS_CONFIG_FILENAME" \
    --request PATCH \
    https://workstations.googleapis.com/v1alpha1/projects/${PROJECT}/locations/${REGION}/workstationClusters/${CLUSTER_NAME}/workstationConfigs/${WS_CONFIG_NAME}?update_mask=${PARAMETER}
}

get_workstationConfig
#update_workstationConfig
