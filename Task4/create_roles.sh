#!/usr/bin/env bash
set -euo pipefail

# Создаём группу SRE (админы кластера)
cat <<'YAML' | minikube kubectl apply -- -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sre-cluster-admin
subjects:
- kind: Group
  name: sre
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
YAML

# Создаём роль для ro-доступа
cat <<'YAML' | minikube kubectl apply -- -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kucold
rules:
- apiGroups: [""]
  resources:
    - namespaces
    - pods
    - pods/log
    - services
    - endpoints
    - configmaps
    - events
  verbs: ["get", "list", "watch"]
- apiGroups: ["apps"]
  resources: ["deployments","replicasets","statefulsets","daemonsets"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["batch"]
  resources: ["jobs","cronjobs"]
  verbs: ["get", "list", "watch"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses","networkpolicies"]
  verbs: ["get", "list", "watch"]
YAML

cat <<'YAML' | minikube kubectl apply -- -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: support-readonly
subjects:
- kind: Group
  name: support
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: kucold
  apiGroup: rbac.authorization.k8s.io
YAML