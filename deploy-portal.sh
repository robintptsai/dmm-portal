#!/bin/bash

echo "deploy-portal.sh...START"

image=$1
namespace=$2
replicas=$3
K8S_CONTEXT=$4


if [[ ! -n "${image}" ]] ;then
    echo "not input docker image path!"
        exit -1
fi

if [[ ! -n "${namespace}" ]] ;then
    echo "not input namespace"
        exit -1
fi

if [[ ! -n "${outboundCount}" ]] ;then
    outboundCount=11
fi

echo "image: "${image}
echo "namespace: "${namespace}
echo "replicas: "${replicas}
echo "aks cluster: "${K8S_CONTEXT}


IFS='.' read -r -a array <<< "$image"
# create ecr secret start
ACCOUNT=${array[0]}                                     #aws account number
REGION=${array[3]}                                     #aws ECR region
SECRET_NAME=regcred                                    #secret_name
EMAIL=abc@xyz.com                                     #can be anything

echo "ACCOUNT="${ACCOUNT}
echo "REGION="${REGION}
echo "SECRET_NAME="${SECRET_NAME}
echo "EMAIL="${EMAIL}

echo "get TOKEN..."
TOKEN=`aws ecr --profile dmm-ecr --region=${REGION} get-authorization-token --output text --query authorizationData[].authorizationToken | base64 -d | cut -d: -f2`
echo "TOKEN="$TOKEN


echo "create ECR secret..."
kubectl -n ${namespace} delete secret --ignore-not-found ${SECRET_NAME}
kubectl -n ${namespace} create secret docker-registry ${SECRET_NAME} \
 --docker-server=https://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com \
 --docker-username=AWS \
 --docker-password="${TOKEN}" \
 --docker-email="${EMAIL}"

# create ecr secret end


echo "##################start deploy replicas ${replicas} ${image}##################"
echo ${image}
echo ${namespace}
echo ${K8S_CONTEXT}
echo "sed ...."
sed s%IMAGE_PLACEHOLDER%${image}% ./ops.yaml | sed s%NAMESPACE_PLACEHOLDER%${namespace}% | sed s%REPLICAS_PLACEHOLDER%${replicas}% |kubectl --context="${K8S_CONTEXT}" apply -f - --record

echo "kubectl -f porta-svc.yaml..."
kubectl -f portal-svc.yaml


echo "deploy-portal.sh...END"


