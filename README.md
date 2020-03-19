# PX-Central Onprem Operator

## Getting started:

### Pre-requisites:
- Kubernetes version supported : 1.14.x, 1.15.x, 1.16.x
- Minimum 4 node k8s cluster (1 master, 3 workers)
- CPU: 4, Memory: 8GB, Drives: 2  needed on each k8s worker node
- To install portworx service needs some unused drives on each worker node. (PxCentral px cluster uses all the available drives.)

Use install.sh script to install px-central on k8s cluster.

```
Usage: ./install.sh

    --license-password <License server admin user password. Note: Please use at least one special symbol and numeric value> Supported special symbols are: [!@#$%]

Required only with OIDC:
    --oidc-clientid <OIDC client-id>
    --oidc-secret <OIDC secret>
    --oidc-endpoint <OIDC endpoint>

Optional:
    --cluster-name <PX-Central Cluster Name>
    --admin-user <Admin user for PX-Central and Grafana>
    --admin-password <Admin user password>
    --admin-email <Admin user email address>
    --kubeconfig <Kubeconfig file>
    --custom-registry <Custom image registry path>
    --image-repo-name <Image repo name>
    --air-gapped <Specify for airgapped environment>
    --image-pull-secret <Image pull secret for custom registry>
    --pxcentral-endpoint <Any one of the master or worker node IP of current k8s cluster>
    --cloud <For cloud deployment specify endpoint as 'loadbalance endpoint'>
    --openshift <Provide if deploying PX-Central on openshift platform>

Examples:
    # Deploy PX-Central without OIDC:
    ./install.sh --license-password 'Adm1n!Ur'

    # Deploy PX-Central with OIDC:
    ./install.sh --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b --oidc-endpoint X.X.X.X:Y --license-password 'Adm1n!Ur'

    # Deploy PX-Central without OIDC with user input kubeconfig:
    ./install.sh --license-password 'Adm1n!Ur' --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with OIDC, custom registry with user input kubeconfig:
    ./install.sh  --license-password 'W3lc0m3#' --oidc-clientid test --oidc-secret 0df8ca3d-7854-ndhr-b2a6-b6e4c970968b  --oidc-endpoint X.X.X.X:Y --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central with custom registry:
    ./install.sh  --license-password 'W3lc0m3#' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central with custom registry with user input kubeconfig:
    ./install.sh  --license-password 'W3lc0m3#' --custom-registry xyz.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret --kubeconfig /tmp/test.yaml

    # Deploy PX-Central on openshift
    ./install.sh  --license-password 'W3lc0m3#' --openshift

    # Deploy PX-Central on openshift on aws
    ./install.sh  --license-password 'W3lc0m3#' --openshift --cloud --pxcentral-endpoint abcxyz.us-east-1.elb.amazonaws.com

    # Deploy PX-Central on air-gapped environment
    ./install.sh  --license-password 'W3lc0m3#' --air-gapped --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret

    # Deploy PX-Central on air-gapped envrionemt with oidc
    ./install.sh  --license-password 'W3lc0m3#' --oidc-clientid test --oidc-secret 87348ca3d-1a73-907db-b2a6-87356538  --oidc-endpoint X.X.X.X:Y --custom-registry test.ecr.us-east-1.amazonaws.com --image-repo-name pxcentral-onprem --image-pull-secret docregistry-secret
```

1. If OIDC is not enabled then access the PxCentral UI and Grafna using the credentials which provided to install script, default credentials are : 
`user: pxadmin` and `email: "pxadmin@portworx.com"` and `password: "Password1"`

2. If OIDC is enabled then to access both PxCentral UI and Grafana used the valid oidc credentials.
