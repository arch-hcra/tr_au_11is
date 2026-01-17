#!/bin/bash
set -e

CLUSTER_NAME=${CLUSTER_NAME:-production}
KUBECONFIG_PATH=${KUBECONFIG_PATH:-$HOME/.kube/config}

echo " Starting deployment to cluster: $CLUSTER_NAME"

# Validate kubeconfig
if [ ! -f "$KUBECONFIG_PATH" ]; then
    echo " Kubeconfig not found at $KUBECONFIG_PATH"
    exit 1
fi

# Export for kustomize
export KUBECONFIG=$KUBECONFIG_PATH

# Function to deploy with validation
deploy_kustomization() {
    local path=$1
    local name=$2
    
    echo " Deploying $name from $path"
    
    # Build and validate
    kustomize build "$path" --load-restrictor LoadRestrictionsNone > /tmp/manifests.yaml
    kubectl apply --validate=true --dry-run=client -f /tmp/manifests.yaml
    
    # Actual apply
    kubectl apply -f /tmp/manifests.yaml
    
    echo " $name deployed successfully"
}

# Deploy in order
deploy_kustomization "infrastructure/base" "base components"
deploy_kustomization "infrastructure/clusters/$CLUSTER_NAME" "cluster configuration"

echo " Deployment completed successfully!"
