# Lagrangian caVAE Training Instructions

This repository contains instructions for running training experiments for the Lagrangian caVAE model. 

## 1. Running on CHTC Cluster
These steps outline the process for submitting jobs to the CHTC cluster.

### Setup & Installation
1.  **Prepare the Directory**
    Copy the following files into your main working directory:
    * `lagrangian_cavae.sub`
    * `run_training.sh`
    * `submit_cavae.sh`
    * `training_files.diff`
    * `restrict_to_horizontal.diff`

2.  **Clone the Repository**
    Clone the Lagrangian_caVAE repository into the same folder:
    ```bash
    git clone https://github.com/DesmondZhong/Lagrangian_caVAE.git
    ```

3.  **Apply Training Patch**
    Navigate into the cloned repository and apply the training configuration patch:
    ```bash
    cd Lagrangian_caVAE
    patch -p1 < ../training_files.diff
    ```

### Execution
**1. Standard Pendulum Training**
Navigate back to the main directory (where the submission scripts are) and submit the job:
```bash
cd ..
./submit_cavae.sh pend_lag_cavae_trainer.py 1 1000
```

**2. Restricted Horizontal Pendulum**
To restrict the pendulum to the horizontal level, follow these additional steps:

* **Apply the Patch:**
    ```bash
    cd Lagrangian_caVAE
    patch -p1 < ../restrict_to_horizontal.diff
    cd ..
    ```

* **Update `run_training.sh`:**
    Open `run_training.sh` and add the dataset generation command before the python training command:
    ```bash
    xvfb-run -s "-screen 0 1400x900x24" python datasets/pend_dataset.py
    ```

* **Consistency Check (Important):**
    Ensure that the `.pkl` file name is identical in both `prepare_dataset.py` and `pend_lag_cavae_trainer.py`.

* **Submit Job:**
    ```bash
    ./submit_cavae.sh pend_lag_cavae_trainer.py 1 1000
    ```

### Configuration & Outputs

* **High-Memory Tasks:** To run `cartpole` or `acrobot` examples, you must open `lagrangian_cavae.sub` and increase the memory request to at least **32GB**.
* **GPU Selection:** To request a specific GPU, refer to the [CHTC GPU Jobs documentation](https://chtc.cs.wisc.edu/uw-research-computing/gpu-jobs) and modify `lagrangian_cavae.sub` accordingly.
* **Logs:** Training logs are saved in the `trained_logs` folder, segregated by epoch sub-folders.
* **Checkpoints:** Successful runs write files to the `checkpoints` folder (e.g., inside `pend-lag-cavae`).

---

## 2. Running Locally (Docker)
To run experiments on your local machine instead of the cluster, use the provided Docker image.

### Step 1: Get the Docker Image
**Option A: Pull Image (Recommended)**
```bash
docker pull hagarwal23/cavae:gpu2
```

**Option B: Build Image**
If you have the `Dockerfile` locally:
```bash
docker build -t hagarwal23/cavae:gpu2 .
```

### Step 2: Run the Container
Launch the container (ensure NVIDIA Container Toolkit is installed):
```bash
docker run --gpus all -it hagarwal23/cavae:gpu2 /bin/bash
```

### Step 3: Execute Training

**For Standard Training:**
Navigate to the code directory and run the training commands as described in the [Lagrangian_caVAE](https://github.com/DesmondZhong/Lagrangian_caVAE) repository.

**For Restricted Horizontal Pendulum:**
1.  Apply the patch (if not already applied).
2.  Run:
    ```bash
    # 1. Point to archive repos (Fixes the 404 errors)
    echo "deb http://archive.debian.org/debian buster main" > /etc/apt/sources.list
    echo "deb http://archive.debian.org/debian-security buster/updates main" >> /etc/apt/sources.list
    
    
    # 2. Update and install Xvfb AND OpenGL libraries
    apt-get -o Acquire::Check-Valid-Until=false update
    apt-get install -y xvfb python-opengl libgl1-mesa-glx
    ```
3.  Generate the dataset manually inside the container:
    ```bash
    xvfb-run -s "-screen 0 1400x900x24" python datasets/pend_dataset.py
    ```
4.  Proceed with the standard training command.
