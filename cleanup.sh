#!/usr/bin/env bash
usage()
{
cat <<EOEG
Usage: $0 
Optional:
    --kubeconfig <Kubeconfig file>
    --pxcentral-namespace <PX-Central-Onprem cluster namespace>
    --px-store <Cleanup portworx cluster>
Examples:
    ./cleanup.sh --kubeconfig /root/.kube/config
EOEG
exit 1
}

while [ "$1" != "" ]; do
    case $1 in
    --kubeconfig)     shift
                      KC=$1
                      ;;
    --pxcentral-namespace)    shift
                              PXCNAMESPACE=$1
                              ;;
    --px-store)               
                              PX_CLEANUP="true"
                              ;;
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=5
PXCNAMESPACE_DEFAULT="portworx"
PX_BACKUP_NAMESPACE="px-backup"
PXCENTRALCRDNAME="pxcentralonprems.pxcentral.com"
ONPREMDEPLOYMENT="pxcentral-onprem-operator"
PXOPERATORDEPLOYMENT="portworx-operator"
PXCENTRALONPREMCR="pxcentralonprem"
ISOCP311CLUSTER="false"
PX_CLEANUP_REQUIRED="false"

mysqlDeploymentName="pxc-mysql"
grafanaDeploymentName="pxc-grafana"
cassandraStsName="pxc-cortex-cassandra"
postgresqlStsName="pxc-keycloak-postgresql"
keycloakStsName="pxc-keycloak"
etcdStsName="pxc-backup-etcd"
ingressName="pxc-onprem-central-ingress"
cortexDeploymentName="pxc-cortex-ingester"
PXC_MODULES_CONFIG="pxc-modules"

LOGFILE="/tmp/pxcentral-onprem-cleanup.log"
logInfo() {
    echo "$(date): level=info msg=$@" >> "$LOGFILE"
}
logError() {
    echo "$(date): level=error msg=$@" >> "$LOGFILE"
}
logWarning() {
    echo "$(date): level=warning msg=$@" >> "$LOGFILE"
}

start_time=`date +%s`
logInfo "+================================================+"
logInfo "===========PX-Central-Onprem Cleanup Started============"
if [ -z ${PXCNAMESPACE} ]; then
  PXCNAMESPACE=$PXCNAMESPACE_DEFAULT
fi
logInfo "PX-Central-Onprem namespace: $PXCNAMESPACE"
if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
fi
echo ""
echo "Using Kubeconfig: $KC"
logInfo "Using Kubeconfig: $KC"
checkK8sVersion=`kubectl --kubeconfig=$KC version --short | awk -Fv '/Server Version: / {print $3}' 2>&1`
echo "Kubernetes cluster version: $checkK8sVersion"
logInfo "Kubernetes cluster version: $checkK8sVersion"
k8sVersion111Validate=`echo -n $checkK8sVersion | grep -E '1.11'`
k8sVersion112Validate=`echo -n $checkK8sVersion | grep -E '1.12'`
k8sVersion113Validate=`echo -n $checkK8sVersion | grep -E '1.13'`
k8sVersion114Validate=`echo -n $checkK8sVersion | grep -E '1.14'`
k8sVersion115Validate=`echo -n $checkK8sVersion | grep -E '1.15'`
k8sVersion116Validate=`echo -n $checkK8sVersion | grep -E '1.16'`
k8sVersion117Validate=`echo -n $checkK8sVersion | grep -E '1.17'`
if [[ -z "$k8sVersion112Validate" && -z "$k8sVersion113Validate" && -z "$k8sVersion114Validate" && -z "$k8sVersion115Validate" && -z "$k8sVersion116Validate" && -z "$k8sVersion117Validate" ]]; then
  ISOCP311CLUSTER="true"
fi

export dotCount=0
export maxDots=10
function showMessage() {
	msg=$1
	dc=$dotCount
	if [ $dc = 0 ]; then
		i=0
		len=${#msg}
		len=$[$len+$maxDots]	
		b=""
		while [ $i -ne $len ]
		do
			b="$b "
			i=$[$i+1]
		done
		echo -e -n "\r$b"
		dc=1
	else 
		msg="$msg"
		i=0
		while [ $i -ne $dc ]
		do
			msg="$msg."
			i=$[$i+1]
		done
		dc=$[$dc+1]
		if [ $dc = $maxDots ]; then
			dc=0
		fi
	fi
	export dotCount=$dc
	echo -e -n "\r$msg"
}

echo ""
echo "This process may take several minutes. Please wait for it to complete..."
logInfo "This process may take several minutes. Please wait for it to complete..."
crdstatus=`kubectl --kubeconfig=$KC get crd $PXCENTRALCRDNAME 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $crdstatus -eq 0 ]; then
    echo "PX-Central is not running on this k8s cluster."
    logWarning "PX-Central is not running on this k8s cluster."
    exit 1
fi

pxcentralnamespacestatus=`kubectl --kubeconfig=$KC get ns $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | awk '{print $1}' | wc -l 2>&1`
if [ $pxcentralnamespacestatus -eq 0 ]; then
    echo "Input cluster does not have $PXCNAMESPACE namespace."
    logWarning "Input cluster does not have $PXCNAMESPACE namespace."
    exit 1
fi

existing_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.existingpx} 2>&1`
central_px=`kubectl --kubeconfig=$KC get cm $PXC_MODULES_CONFIG --namespace $PXCNAMESPACE -o jsonpath={.data.centralpx} 2>&1`
echo "Existing portworx: $existing_px, Central deployed portworx: $central_px"
if [[ "$existing_px" == "false" && "$central_px" == "true" ]]; then
  PX_CLEANUP_REQUIRED="true"
fi

storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | grep -v "NotFound" | awk '{print $1}' | wc -l 2>&1`
if [ $storageclusterstatus -eq 0 ]; then
    echo "No storage cluster available to delete in $PXCNAMESPACE namespace."
    logInfo "No storage cluster available to delete in $PXCNAMESPACE namespace."
else
    echo "Storage cluster available in $PXCNAMESPACE namespace."
    logInfo "Storage cluster available in $PXCNAMESPACE namespace."
fi

echo "PX-Central cluster cleanup started:"
logInfo "PX-Central cluster cleanup started:"
pxPodsCount=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE -lname=portworx 2>&1 | grep -v "NAME" | grep -v "error" | grep -v "No resources found" | wc -l 2>&1`
echo "Portworx pods count: $pxPodsCount"
logInfo "Portworx pods count: $pxPodsCount"
echo "Started PX-Central-Onprem components deletion:"
logInfo "Started PX-Central-Onprem components deletion:"
if [ "$PX_CLEANUP_REQUIRED" == "true" ]; then
  echo "Portworx cleanup required."
  logInfo "Portworx cleanup required."
fi
if [ "$PX_CLEANUP" == "true" ]; then
  PX_CLEANUP_REQUIRED="true"
  echo "portworx cluster cleanup requested."
  logInfo "portworx cluster cleanup requested."
fi
if [[ $storageclusterstatus -eq 1 && "$PX_CLEANUP_REQUIRED" == "true" ]]; then
    px_operator="/tmp/pxc-px-operator.yaml"
    logInfo "PX Operator spec: $px_operator"
cat <<< '
apiVersion: v1
kind: ServiceAccount
metadata:
  name: portworx-operator-pxc
  namespace: '$PXCNAMESPACE'
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
   name: portworx-operator-pxc
   namespace: '$PXCNAMESPACE'
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
---
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: portworx-operator-pxc
  namespace: '$PXCNAMESPACE'
subjects:
- kind: ServiceAccount
  name: portworx-operator-pxc
  namespace: '$PXCNAMESPACE'
roleRef:
  kind: ClusterRole
  name: portworx-operator-pxc
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: portworx-operator-pxc
  namespace: '$PXCNAMESPACE'
spec:
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  replicas: 1
  selector:
    matchLabels:
      name: portworx-operator-pxc
  template:
    metadata:
      labels:
        name: portworx-operator-pxc
    spec:
      containers:
      - name: portworx-operator
        image: portworx/px-operator:1.3.1
        imagePullPolicy: Always
        command:
        - /operator
        - --verbose
        - --driver=portworx
        - --leader-elect=true
        env:
        - name: OPERATOR_NAME
          value: portworx-operator
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
      serviceAccountName: portworx-operator-pxc
' > $px_operator
    if [ ! -f $px_operator ]; then
        echo "Failed to create file: $px_operator, verify you have right access to create file: $px_operator"
        logError "Failed to create file: $px_operator, verify you have right access to create file: $px_operator"
        echo ""
        exit 1
    fi
    kubectl --kubeconfig=$KC apply -f $px_operator --namespace $PXCNAMESPACE >> "$LOGFILE"
    sleep $SLEEPINTERVAL
    echo "Wait for storage cluster to delete"
    logInfo "Wait for storage cluster to delete"
    pxcentralobject=`kubectl --kubeconfig=$KC get $PXCENTRALONPREMCR --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}'`
    kubectl --kubeconfig=$KC  delete $pxcentralobject $pxcentralobject --namespace $PXCNAMESPACE >> "$LOGFILE"
    kubectl --kubeconfig=$KC patch pvc -p '{"metadata":{"finalizers": []}}' --type=merge --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}' | grep -v NAME) &>/dev/null
    kubectl --kubeconfig=$KC delete pvc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
    sleep $SLEEPINTERVAL
    storageclustername=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' 2>&1`
    kubectl --kubeconfig=$KC delete storagecluster $storageclustername --namespace $PXCNAMESPACE >> "$LOGFILE"
    storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}' | wc -l 2>&1`
    if [ $storageclusterstatus -eq 0 ]; then
        echo "No storage cluster available, deleted which was running in $PXCNAMESPACE namespace."
        logInfo "No storage cluster available, deleted which was running in $PXCNAMESPACE namespace."
    fi
    echo "Storage cluster deleted."
    logInfo "Storage cluster deleted."
    echo ""
elif [[ $pxPodsCount -gt 0 && "$PX_CLEANUP_REQUIRED" == "true" ]]; then
    echo "Portworx cluster cleanup:"
    logInfo "Portworx cluster cleanup:"
    curl -fsL https://install.portworx.com/px-wipe | bash #-s -- --force
    sleep $SLEEPINTERVAL
fi
pxcentralobject=`kubectl --kubeconfig=$KC get $PXCENTRALONPREMCR --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | grep -v "error" | grep -v "No resources found" | awk '{print $1}'`
kubectl --kubeconfig=$KC patch $pxcentralobject -p '{"metadata":{"finalizers": []}}' --type=merge $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC  delete $pxcentralobject $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete ingress $(kubectl --kubeconfig=$KC get ingress --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}' | grep -v NAME 2>&1) --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete crd $PXCENTRALCRDNAME --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC patch pvc -p '{"metadata":{"finalizers": []}}' --type=merge --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}' | grep -v NAME) &>/dev/null
kubectl --kubeconfig=$KC delete pvc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete svc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get svc --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete cm --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get cm --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
if [ "$PX_CLEANUP_REQUIRED" == "true" ]; then
    kubectl --kubeconfig=$KC delete clusterrole $(kubectl --kubeconfig=$KC  get clusterrole 2>&1 | grep px | awk '{print $1}') &>/dev/null
    kubectl --kubeconfig=$KC delete clusterrolebinding $(kubectl --kubeconfig=$KC  get clusterrolebinding 2>&1 | grep px | awk '{print $1}') &>/dev/null
else
    kubectl --kubeconfig=$KC delete clusterrole  $(kubectl --kubeconfig=$KC  get clusterrole 2>&1 | grep -v portworx-operator | grep px | awk '{print $1}') &>/dev/null
    kubectl --kubeconfig=$KC delete clusterrolebinding $(kubectl --kubeconfig=$KC  get clusterrolebinding 2>&1 | grep -v portworx-operator | grep px | awk '{print $1}') &>/dev/null
fi
kubectl --kubeconfig=$KC delete secrets --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get secrets --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete ns $PX_BACKUP_NAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete job ingress-nginx-admission-create $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete job ingress-nginx-admission-patch $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete replicaset ingress-nginx-controller $PXCNAMESPACE &>/dev/null 
kubectl --kubeconfig=$KC delete deployment ingress-nginx-controller $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC delete svc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get svc --namespace $PXCNAMESPACE 2>&1 | grep ingress | awk '{print $1}') &>/dev/null
kubectl --kubeconfig=$KC delete sc $(kubectl --kubeconfig=$KC get sc --namespace $PXCNAMESPACE 2>&1 | grep pxc  | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete deployment portworx-operator-pxc --namespace $PXCNAMESPACE &>/dev/null 
kubectl --kubeconfig=$KC delete deployment pxcentral-onprem-operator --namespace $PXCNAMESPACE &>/dev/null 
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC get ns | grep "$PXCNAMESPACE" >> "$LOGFILE"
kubectl --kubeconfig=$KC get ns | grep "$PX_BACKUP_NAMESPACE" >> "$LOGFILE"
logInfo "After cleanup pods list:"
kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "After cleanup services list:"
kubectl --kubeconfig=$KC get svc --namespace $PXCNAMESPACE &> "$LOGFILE"
logInfo "After cleanup pvc's list:"
kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE &> "$LOGFILE"
echo "PX-Central cluster successfully wiped."
logInfo "PX-Central cluster successfully wiped."
echo ""
central_cleanup_time=$((($(date +%s)-$start_time)/60))
echo "PX-Central-Onprem cluster cleanup time taken: $central_cleanup_time minutes."
logInfo "PX-Central-Onprem cluster cleanup time taken: $central_cleanup_time minutes."
logInfo "===========PX-Central-Onprem Cleanup Done============"
logInfo "+================================================+"
echo ""