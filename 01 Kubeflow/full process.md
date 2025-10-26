**Step-by-step optimal setup** for installing **Kubeflow on a Linux VM in Google Cloud** (like in that [YouTube video](https://youtu.be/bywO8tvetkM)), **but done safely and correctly** — including networking and firewall configuration.

---

## 🧠 Before You Start — Concept Overview

You’ll be setting up this structure:

```
Google Cloud VM (Linux)
 ├── Docker (container runtime)
 ├── Minikube (local Kubernetes cluster)
 ├── Kubeflow (installed on top of Kubernetes)
 └── Jupyter Notebook (served via Kubeflow UI)
```

---

## ⚙️ Step-by-Step Setup Guide (Optimized & Safe)

### **1️⃣ Create Your GCP VM Instance**

Go to [Google Cloud Console → Compute Engine → VM Instances → Create Instance](https://console.cloud.google.com/compute/instances)

**Recommended settings:**

| Setting           | Value                                                   |
| ----------------- | ------------------------------------------------------- |
| **Name**          | kubeflow-lab                                            |
| **Region / Zone** | Choose closest to you                                   |
| **Machine type**  | e2-standard-4 (4 vCPUs, 16GB RAM — needed for Kubeflow) |
| **Boot disk**     | Ubuntu 22.04 LTS, 100GB                                 |
| **Firewall**      | ✅ Allow HTTP, ✅ Allow HTTPS                             |

Then **create** the VM.

---

### **2️⃣ Configure Firewall Rules (but safely)**

You mentioned `0.0.0.0/0` and ports `3000–6000` — this is for accessing Kubeflow’s dashboard and notebooks.

**Best practice:**
✅ Allow those ports **only for your IP** instead of `0.0.0.0/0`.

Run in Cloud Shell (replace YOUR-IP with your actual IP address):

```bash
gcloud compute firewall-rules create kubeflow-access \
  --allow=tcp:3000-6000 \
  --source-ranges=YOUR-IP/32 \
  --target-tags=kubeflow-vm \
  --description="Allow Kubeflow dashboard and notebooks"
```

If you still want to open it fully (not recommended for production):

```bash
gcloud compute firewall-rules create kubeflow-open \
  --allow=tcp:3000-6000 \
  --source-ranges=0.0.0.0/0 \
  --description="Open Kubeflow dashboard (testing only)"
```

Then, edit your VM → add the **network tag** `kubeflow-vm`.

---

### **3️⃣ Connect to VM**

```bash
gcloud compute ssh kubeflow-lab
```

---

### **4️⃣ Install Dependencies**

Update packages:

```bash
sudo apt update && sudo apt upgrade -y
```

Install Docker:

```bash
sudo apt install -y docker.io
sudo usermod -aG docker $USER
newgrp docker
```

Install Minikube:

```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Install kubectl:

```bash
sudo snap install kubectl --classic
```

---

### **5️⃣ Start Minikube**

You can use Docker as the driver (simplest setup):

```bash
minikube start --driver=docker --memory=8192 --cpus=4
```

Check that it’s running:

```bash
kubectl get nodes
```

---

### **6️⃣ Install Kubeflow**

There are several methods. For learning, use **Kubeflow MiniKF** or **Manifests** install.

Here’s a simple way using `kfctl`:

```bash
wget https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-ga476281_linux.tar.gz
tar -xvf kfctl_v1.2.0-0-ga476281_linux.tar.gz
sudo mv kfctl /usr/local/bin
```

Set environment variables:

```bash
export KF_NAME=kubeflow
export BASE_DIR=$HOME
export KF_DIR=${BASE_DIR}/${KF_NAME}
mkdir -p ${KF_DIR}
cd ${KF_DIR}
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_k8s_istio.v1.2.0.yaml"
```

Deploy Kubeflow:

```bash
kfctl apply -V -f ${CONFIG_URI}
```

This will take **10–20 minutes** depending on your network.

---

### **7️⃣ Access the Kubeflow Dashboard**

Once installation finishes, you can check the services:

```bash
kubectl get pods -n kubeflow
kubectl get svc -n kubeflow
```

Then, enable port forwarding:

```bash
kubectl port-forward -n istio-system svc/istio-ingressgateway 8080:80
```

Now open your browser and visit:
👉 `http://<your-external-vm-ip>:8080`

You should see the **Kubeflow dashboard**.

---

### **8️⃣ Create a Jupyter Notebook Server**

* In the Kubeflow UI, go to **Notebooks** → **New Notebook**.
* Choose image: `tensorflow:latest` or `pytorch:latest`.
* Set CPU (2) and memory (4–8 GB).
* Click **Launch**.
* When ready, click **Connect** — it opens a full Jupyter notebook in your browser.

---

### **9️⃣ Save & Backup (Optional but Good)**

After setup, take a snapshot of your VM so you can restore it later.

---

## 🚨 Security Tips

* **Do NOT keep 0.0.0.0/0 open permanently** — close the rule when done:

  ```bash
  gcloud compute firewall-rules delete kubeflow-open
  ```
* Always restrict access to your IP when possible.
* Stop your VM when not using to save costs:

  ```bash
  gcloud compute instances stop kubeflow-lab
  ```

---

## 🎯 Final Notes

After completing this setup, you will:
✅ Have a full Kubeflow stack running on GCP.
✅ Understand Kubernetes + MLOps pipeline basics.
✅ Be able to run Jupyter notebooks inside the Kubeflow UI.
✅ Have something impressive to showcase in your resume or interview (“Deployed Kubeflow on Google Cloud VM and built ML workflows using Minikube”).

---

## [**ready-to-run automated setup script** for installing **Kubeflow on a Google Cloud VM** (Ubuntu 22.04)](/01%20Kubeflow/README.md)