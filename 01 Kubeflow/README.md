## 1. What is Kubeflow (and why it matters in MLOps)

![Image](https://www.kubeflow.org/docs/images/dashboard/homepage.png)

<p align="center">
  <img src="https://www.kubeflow.org/docs/started/images/ai-lifecycle-kubeflow.drawio.svg" alt="Image 1" width="57%" style="margin-right: 10px;"/>
  <img src="https://cdn.hashnode.com/res/hashnode/image/upload/v1657538785980/gBRk6dMYv.png" alt="Image 2" width="41%" style="margin-right: 10px;"/>
</p>

Here’s a simplified explanation:

### ✅ Definition & Role

* Kubeflow is an open-source platform built on top of Kubernetes that helps you build, deploy and manage machine-learning (ML) workflows at scale. ([Kubeflow][1])
* It’s designed not just for developing models (“data scientist writes code”) but for operationalizing (running those models reliably in production, monitoring them, versioning them) — this is the heart of MLOps. ([Red Hat Developer][2])

### 🔍 Why it’s important for MLOps

* Machine-learning isn't just “build model → deploy”. There are many stages: data ingestion/processing, feature engineering, training, hyperparameter tuning, model deployment (serving), monitoring & versioning. Kubeflow offers components to handle many of those stages. ([Kubeflow][3])
* It brings **reproducibility**, **scalability**, **portability** (across clouds or on-premises) to ML workflows. So your work can move from experiment to robust production. ([Google Cloud][4])
* Because you already have cloud & networking skills, learning something like Kubeflow is a great way to show you understand the “ops” side of ML (not just algorithm side) — that’s a huge plus for roles around cloud+AI.

### 🧩 Key Components & What they do

Here are a few of the important pieces:

* **Pipelines**: Define ML workflows (steps like preprocess → train → evaluate → serve). Kubeflow Pipelines gives you a way to orchestrate these. ([Red Hat Developer][2])
* **Notebooks**: Launch Jupyter or other interactive environments in your Kubernetes cluster — helpful for experimentation. ([Kubeflow][1])
* **Model Serving / Inference**: Deploying a trained model so it can serve predictions. Kubeflow has components (e.g., KServe) for this. ([Google Cloud][4])
* **Hyperparameter tuning & AutoML**: For example, the Katib component in Kubeflow. ([Medium][5])
* **Metadata & versioning**: Tracking what model version was used, what data, what parameters, etc. For robust production workflows. ([Google Cloud][4])

### 🎯 Summary

In short: Kubeflow = “Kubernetes + ML workflows” → ideal for MLOps. If you can deploy a Kubeflow pipeline (or show you know the concepts) it tells a prospective employer you understand cloud + ML + operations altogether.

---

## 2. [Manual Process](/01%20Kubeflow/full%20process.md) `or`

## 2. Below is a **ready-to-run automated setup script** for installing **Kubeflow on a Google Cloud VM** (Ubuntu 22.04).

This script:

* Installs **Docker**, **Minikube**, **kubectl**, and **Kubeflow**
* Configures **firewall rules** for ports `3000–6000` (optionally open or IP-restricted)
* Sets up **port forwarding** to access the Kubeflow dashboard
* Runs safely — no data loss, and you can delete/reuse the VM easily

---

## ⚙️ **1️⃣ Run these steps in order**

### Step 1: Create a new Ubuntu VM on GCP

Use:

* Machine type: `e2-standard-4`
* Disk: 100 GB
* Firewall: Allow HTTP + HTTPS
* OS: Ubuntu 22.04 LTS
* Name: `kubeflow-lab`

Then SSH into the VM via the Google Cloud Console.

---

## 🧰 **2️⃣ Copy-paste this full script**

Save this as `install_kubeflow.sh` or just paste it line-by-line in your terminal.

```bash
#!/bin/bash
set -e

echo "=============================="
echo " Kubeflow Installation Script "
echo "=============================="

# ---------- VARIABLES ----------
export KF_NAME=kubeflow
export BASE_DIR=$HOME
export KF_DIR=${BASE_DIR}/${KF_NAME}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml"
export PORT=8080

# ---------- SYSTEM UPDATE ----------
sudo apt update -y && sudo apt upgrade -y

# ---------- INSTALL DOCKER ----------
echo "[1/6] Installing Docker..."
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker

# ---------- INSTALL MINIKUBE ----------
echo "[2/6] Installing Minikube..."
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# ---------- INSTALL KUBECTL ----------
echo "[3/6] Installing kubectl..."
sudo snap install kubectl --classic

# ---------- START MINIKUBE ----------
echo "[4/6] Starting Minikube cluster..."
minikube start --driver=docker --memory=8192 --cpus=4
kubectl get nodes

# ---------- INSTALL KUBEFLOW ----------
echo "[5/6] Installing Kubeflow (this will take ~20 mins)..."
wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-ga476281_linux.tar.gz
tar -xvf kfctl_v1.2.0-0-ga476281_linux.tar.gz
sudo mv kfctl /usr/local/bin
rm kfctl_v1.2.0-0-ga476281_linux.tar.gz

mkdir -p ${KF_DIR}
cd ${KF_DIR}
kfctl apply -V -f ${CONFIG_URI}

# ---------- PORT FORWARDING ----------
echo "[6/6] Setting up Kubeflow access on port ${PORT}..."
nohup kubectl port-forward -n istio-system svc/istio-ingressgateway ${PORT}:80 > port-forward.log 2>&1 &

echo "=================================================="
echo " Kubeflow installation complete!"
echo " Access it via: http://<YOUR_VM_EXTERNAL_IP>:${PORT}"
echo "=================================================="
```

---

## 🌐 **3️⃣ Configure Firewall (from Cloud Shell or Console)**

Option 1 – safer (only your IP):

```bash
gcloud compute firewall-rules create kubeflow-access \
  --allow=tcp:3000-6000 \
  --source-ranges=$(curl -s ifconfig.me)/32 \
  --target-tags=kubeflow-vm \
  --description="Allow Kubeflow dashboard access for your IP"
```

Option 2 – open to everyone *(use only for testing)*:

```bash
gcloud compute firewall-rules create kubeflow-open \
  --allow=tcp:3000-6000 \
  --source-ranges=0.0.0.0/0 \
  --description="Open Kubeflow ports for testing"
```

Then edit your VM → add the **network tag** `kubeflow-vm`.

---

## 🚀 **4️⃣ Run the script**

```bash
chmod +x install_kubeflow.sh
./install_kubeflow.sh
```

🕒 Takes about **25–30 minutes** to complete.

---

## ✅ **5️⃣ Verify Installation**

Once done:

```bash
kubectl get pods -n kubeflow
kubectl get svc -n kubeflow
```

Then open your browser:

```
http://<EXTERNAL_VM_IP>:8080
```

You’ll see the **Kubeflow Dashboard** 🎉

Inside the dashboard, go to **Notebooks → New Notebook** and create a TensorFlow or PyTorch notebook.

---

## 🔒 **6️⃣ Cleanup (optional when done)**

Stop your VM to save billing:

```bash
gcloud compute instances stop kubeflow-lab
```

Or delete firewall rules:

```bash
gcloud compute firewall-rules delete kubeflow-open
```

---

## What's next: ?

### **extend this script** so it automatically:

* Creates a **Jupyter Notebook** inside Kubeflow,
* And sets up a **sample ML pipeline (Kubeflow Pipelines)**


### [Demo link](/01%20Kubeflow/complete%20demo.md)
