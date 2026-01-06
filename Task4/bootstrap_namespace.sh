#!/usr/bin/env bash
set -euo pipefail

namespaces=( "$@" )

for ns in "${namespaces[@]}"; do

  echo namespace "$ns"...
  # создаём namespace
  cat <<YAML | minikube kubectl apply -- -f -
apiVersion: v1
kind: Namespace
metadata:
  name: $ns
YAML

  # роль разработчика
  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${ns}-deployer
  namespace: ${ns}
rules:
- apiGroups: [""]
  resources: ["pods","pods/log","services","endpoints","configmaps","events"]
  verbs: ["get","list","watch","create","update","patch","delete"]
- apiGroups: ["apps"]
  resources: ["deployments","replicasets","statefulsets","daemonsets"]
  verbs: ["get","list","watch","create","update","patch","delete"]
- apiGroups: ["batch"]
  resources: ["jobs","cronjobs"]
  verbs: ["get","list","watch","create","update","patch","delete"]
- apiGroups: ["networking.k8s.io"]
  resources: ["ingresses"]
  verbs: ["get","list","watch","create","update","patch","delete"]
YAML

  # роль devops
  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${ns}-ops
  namespace: ${ns}
rules:
- apiGroups: ["*"]
  resources: ["*"]
  verbs: ["get","list","watch","create","update","patch","delete"]
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get","list","watch"]
YAML

  # роль ИБ-шника (и некоторых devops)
  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${ns}-secret-manager
  namespace: ${ns}
rules:
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get","list","watch","create","update","patch","delete"]
YAML

  # биндим
  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-developer-${ns}
  namespace: ${ns}
subjects:
- kind: Group
  name: developer
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: ${ns}-deployer
  apiGroup: rbac.authorization.k8s.io
YAML

  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-devops-${ns}
  namespace: ${ns}
subjects:
- kind: Group
  name: devops
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: ${ns}-ops
  apiGroup: rbac.authorization.k8s.io
YAML

  cat <<YAML | minikube kubectl -- apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: rb-security-${ns}
  namespace: ${ns}
subjects:
- kind: Group
  name: security
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: ${ns}-secret-manager
  apiGroup: rbac.authorization.k8s.io
YAML

done
