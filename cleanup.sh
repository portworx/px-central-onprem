#!/usr/bin/env bash
usage()
{
cat <<EOEG
Usage: $0 

Optional:
    --kubeconfig <Kubeconfig file>

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
    -h | --help )   usage
                    ;;
    * )             usage
    esac
    shift
done

TIMEOUT=1800
SLEEPINTERVAL=5
PXCNAMESPACE="kube-system"
PXCENTRALCRDNAME="pxcentralonprems.pxcentral.com"
ONPREMDEPLOYMENT="pxcentral-onprem-operator"
PXOPERATORDEPLOYMENT="portworx-operator"
PXCENTRALONPREMCR="pxcentralonprem"

if [ -z ${KC} ]; then
  KC=$KUBECONFIG
fi

if [ -z ${KC} ]; then
    KC="$HOME/.kube/config"
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
crdstatus=`kubectl --kubeconfig=$KC get crd $PXCENTRALCRDNAME 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [ $crdstatus -eq "0" ]; then
    echo "PX-Central is not running on this k8s cluster."
    exit 1
fi

pxcentralnamespacestatus=`kubectl --kubeconfig=$KC get ns $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [ $pxcentralnamespacestatus -eq "0" ]; then
    echo "Input cluster does not have kube-system namespace."
    exit 1
fi

storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [ $storageclusterstatus -eq "0" ]; then
    echo "No storage cluster available to delete in kube-system namespace."
fi

echo "PX-Central cluster cleanup started:"
echo ""
echo "This process may take several minutes. Please wait for it to complete..."
kubectl --kubeconfig=$KC scale deployment $ONPREMDEPLOYMENT --namespace $PXCNAMESPACE --replicas=0 &>/dev/null
sleep $SLEEPINTERVAL

echo "Wait for storage cluster to delete"
storageclustername=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' 2>&1`
kubectl --kubeconfig=$KC delete storagecluster $storageclustername --namespace $PXCNAMESPACE &>/dev/null

storageclusterstatus=`kubectl --kubeconfig=$KC get storagecluster --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | wc -l 2>&1`
if [ $storageclusterstatus -eq "0" ]; then
    echo "No storage cluster available to delete in kube-system namespace."
fi
echo "Storage cluster deleted."
echo ""

pxcentralobject=`kubectl --kubeconfig=$KC get $PXCENTRALONPREMCR --namespace $PXCNAMESPACE 2>&1 |  grep -v NAME | awk '{print $1}'`
kubectl --kubeconfig=$KC patch $pxcentralobject -p '{"metadata":{"finalizers": []}}' --type=merge $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
kubectl --kubeconfig=$KC  delete $pxcentralobject $pxcentralobject --namespace $PXCNAMESPACE &>/dev/null
stackcheck="0"
timecheck=0
while [ $stackcheck -ne "1" ]
    do
        pod_count=`kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE 2>&1 | grep -v NAME | awk '{print $1}' | grep "pxc-" | wc -l`
        if [ $pod_count -lt 1 ]; then
            stackcheck="1"
            break
        fi
        showMessage "PX-Central cluster cleanup is in progress..."
        timecheck=$[$timecheck+$SLEEPINTERVAL]
        if [ $timecheck -gt $TIMEOUT ]; then
            echo "Failed to cleanup PX-Central cluster, TIMEOUT: $TIMEOUT"
            exit 1
        fi
        sleep $SLEEPINTERVAL
        kubectl --kubeconfig=$KC delete pod  --grace-period=0 --force $(kubectl --kubeconfig=$KC get po --namespace $PXCNAMESPACE  2>&1 | grep -i "pxc" | awk '{print $1}') --namespace $PXCNAMESPACE &>/dev/null
    done

kubectl --kubeconfig=$KC  delete crd $PXCENTRALCRDNAME --namespace $PXCNAMESPACE &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC patch pvc -p '{"metadata":{"finalizers": []}}' --type=merge --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC get pvc --namespace $PXCNAMESPACE 2>&1 | awk '{print $1}' | grep -v NAME) &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete pvc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get pvc --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete svc --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get svc --namespace $PXCNAMESPACE 2>&1 | grep px | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete cm --namespace $PXCNAMESPACE $(kubectl --kubeconfig=$KC  get cm --namespace $PXCNAMESPACE 2>&1 | grep pxc | awk '{print $1}') &>/dev/null
sleep $SLEEPINTERVAL
echo ""
sleep $SLEEPINTERVAL
kubectl --kubeconfig=$KC delete sc $(kubectl --kubeconfig=$KC get sc --namespace $PXCNAMESPACE 2>&1 | grep pxc  | awk '{print $1}') &>/dev/null
echo "PX-Central cluster successfully wiped."