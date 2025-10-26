# Start minikube
minikube delete
minikube start --cpus 6 --memory 12288 --disk-size=120g --driver=none
sudo chmod 777 -R ~/.kube

# Installation of Kubeflow
sudo rm -rf ~/kubeflow
mkdir -p ~/kubeflow/v1.2
cd ~/kubeflow/v1.2
# Install kfctl
wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz
	
export PATH=$PATH:~/kubeflow/v1.2
export KF_NAME=my-kubeflow
export BASE_DIR=~/kubeflow/v1.2
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml" 

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}
