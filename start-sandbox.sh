#!/bin/bash
echo "🚀 Startuji K8s Sandbox (Kind)..."
if ! command -v kind &> /dev/null; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
fi
cat <<EOT > kind-config.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
EOT
kind create cluster --name sandbox-cluster --config kind-config.yaml
echo "✅ Sandbox hotov! 'kubectl get nodes' pro kontrolu."
