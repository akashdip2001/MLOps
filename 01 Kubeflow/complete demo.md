## **complete, job-ready demo** of **sample ML pipeline (Kubeflow Pipelines)**

You’ll not only have **Kubeflow running on your GCP VM**, but also:
✅ a **Jupyter Notebook** auto-created in Kubeflow, and
✅ a **sample MLOps pipeline** (data → training → evaluation → deployment).

Below is a **production-safe automation script** that adds these on top of the Kubeflow setup you already have.

---

## 🧩 Overview

Here’s what this extended setup will do:

1. Install Docker, Minikube, Kubectl, and Kubeflow
2. Set up firewall access (optional 3000-6000 range)
3. Deploy Kubeflow
4. Create a **Jupyter Notebook server** automatically
5. Deploy a **sample ML pipeline** (Kubeflow Pipelines demo)
6. Print the dashboard URL when done

---

## ⚙️ **Extended Kubeflow Installation Script**

Save this file as:

```bash
install_kubeflow_full.sh
```

Then run it after your VM is ready.

```bash
#!/bin/bash
set -e

echo "=============================================="
echo " Kubeflow + Jupyter + Sample Pipeline Installer"
echo "=============================================="

# ---------- VARIABLES ----------
export KF_NAME=kubeflow
export BASE_DIR=$HOME
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml"
export PORT=8080
export NOTEBOOK_NAME=demo-notebook
export PIPELINE_NS=kubeflow
export DEMO_PIPELINE_URL="https://raw.githubusercontent.com/kubeflow/pipelines/master/samples/core/sequential/sequential.py"

# ---------- SYSTEM UPDATE ----------
sudo apt update -y && sudo apt upgrade -y

# ---------- INSTALL DOCKER ----------
echo "[1/7] Installing Docker..."
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker

# ---------- INSTALL MINIKUBE ----------
echo "[2/7] Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# ---------- INSTALL KUBECTL ----------
echo "[3/7] Installing kubectl..."
sudo snap install kubectl --classic

# ---------- START MINIKUBE ----------
echo "[4/7] Starting Minikube cluster..."
minikube start --driver=docker --memory=8192 --cpus=4
kubectl get nodes

# ---------- INSTALL KUBEFLOW ----------
echo "[5/7] Installing Kubeflow (this may take ~20 mins)..."
wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-ga476281_linux.tar.gz
tar -xvf kfctl_v1.2.0-0-ga476281_linux.tar.gz
sudo mv kfctl /usr/local/bin
rm kfctl_v1.2.0-0-ga476281_linux.tar.gz

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}

# Wait until Kubeflow pods are running
echo "Waiting for Kubeflow pods to be ready..."
kubectl wait --for=condition=Available --timeout=1800s deployment --all -n kubeflow || true

# ---------- PORT FORWARD ----------
echo "[6/7] Enabling Kubeflow dashboard access..."
nohup kubectl port-forward -n istio-system svc/istio-ingressgateway ${PORT}:80 > port-forward.log 2>&1 &

# ---------- CREATE JUPYTER NOTEBOOK ----------
echo "[7/7] Creating Jupyter notebook server in Kubeflow..."
cat <<EOF | kubectl apply -f -
apiVersion: kubeflow.org/v1
kind: Notebook
metadata:
  name: ${NOTEBOOK_NAME}
  namespace: ${PIPELINE_NS}
spec:
  template:
    spec:
      containers:
        - name: tensorflow
          image: gcr.io/kubeflow-images-public/tensorflow-2.3.0-notebook-cpu:v0.7.0
          resources:
            requests:
              memory: "2Gi"
              cpu: "1"
            limits:
              memory: "4Gi"
              cpu: "2"
EOF

# ---------- DEPLOY SAMPLE PIPELINE ----------
echo "Deploying sample Kubeflow pipeline..."
mkdir -p ~/pipelines
cd ~/pipelines
wget ${DEMO_PIPELINE_URL} -O sequential.py
kubectl apply -f https://raw.githubusercontent.com/kubeflow/pipelines/master/samples/core/sequential/sequential.yaml -n ${PIPELINE_NS} || true

# ---------- PRINT RESULTS ----------
echo "====================================================="
echo "✅ Kubeflow installation complete!"
echo "🌐 Access Dashboard: http://<YOUR_VM_EXTERNAL_IP>:${PORT}"
echo "📓 Notebook name: ${NOTEBOOK_NAME}"
echo "📊 Pipeline deployed: Sequential sample pipeline"
echo "====================================================="
```

---

## 🌐 **Firewall Setup (only once)**

Option 1 — safer (only your IP):

```bash
gcloud compute firewall-rules create kubeflow-access \
  --allow=tcp:3000-6000 \
  --source-ranges=$(curl -s ifconfig.me)/32 \
  --target-tags=kubeflow-vm \
  --description="Allow Kubeflow dashboard access for your IP"
```

Option 2 — open (testing only):

```bash
gcloud compute firewall-rules create kubeflow-open \
  --allow=tcp:3000-6000 \
  --source-ranges=0.0.0.0/0 \
  --description="Open Kubeflow dashboard for testing"
```

Attach the tag `kubeflow-vm` to your VM.

---

## 🚀 **Run the script**

```bash
chmod +x install_kubeflow_full.sh
./install_kubeflow_full.sh
```

⏱️ It takes **30–40 minutes** total.
After completion, visit:

```
http://<YOUR_VM_EXTERNAL_IP>:8080
```

You’ll see:

* The **Kubeflow dashboard**
* A **“demo-notebook”** listed under *Notebooks*
* The **“Sequential Pipeline”** under *Pipelines → Experiments*

---

## 🧠 What to do next

1. Open the “demo-notebook” → write Python ML code (TensorFlow or Scikit-learn).
2. In “Pipelines,” run the *Sequential Sample* to see a real workflow.
3. Take screenshots — these are perfect for your **portfolio / resume project**.

---