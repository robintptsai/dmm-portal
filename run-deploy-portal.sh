echo "run-deploy-portal.sh...START"

echo "ECR: 067240665187.ecr.aws.com"
echo "namespace: dm-int"
echo "replica: 1"
echo "cluster: aks-dmm-poc"


echo "./deploy-portal.sh "
./deploy-portal.sh 067240665187.dkr.ecr.us-west-2.amazonaws.com/dm-portal:1.0.142 dm-int 1 aks-dmm-poc




echo "run-deploy-portal.sh...END"
