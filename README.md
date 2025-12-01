# Lagrangian caVAE Training Instructions

This repository contains the setup and scripts required to run training experiments for the Lagrangian caVAE model, including specific configurations for the Pendulum, Cartpole, and Acrobot environments.

## 1. Setup and Installation

### Prepare the Directory
1. Ensure the following script and submission files are present in your working directory:
   - `lagrangian_cavae.sub`
   - `run_training.sh`
   - `submit_cavae.sh`

2. Clone the [Lagrangian_caVAE](https://github.com/DesmondZhong/Lagrangian_caVAE) repository into this same directory:
   ```bash
   git clone [https://github.com/DesmondZhong/Lagrangian_caVAE](https://github.com/DesmondZhong/Lagrangian_caVAE)
   ```

3. Apply the training configuration patch:
   ```bash
   patch -p1 < training_files.diff
   ```

## 2. Running Experiments

### Standard Pendulum Training
To submit a training job for the pendulum environment, run the submission script with the trainer file, seed, and epochs:

```bash
./submit_cavae.sh pend_lag_cavae_trainer.py 1 1000
```

### Restricted Horizontal Pendulum
To restrict the pendulum to the horizontal level:
1. Apply the restriction patch:
   ```bash
   patch -p1 < restrict_to_horizontal.diff
   ```
2. Run the submission command as shown in the standard step above.

## 3. Configuration for Advanced Tasks

### High-Memory Environments (Cartpole / Acrobot)
If you intend to run the `cartpole` or `acrobot` examples, the default memory allocation may be insufficient.
- Open `lagrangian_cavae.sub`.
- Increase the requested memory to **at least 32GB**.

### GPU Selection
To request a specific GPU architecture for your jobs:
1. Refer to the [CHTC GPU Jobs Documentation](https://chtc.cs.wisc.edu/uw-research-computing/gpu-jobs).
2. Modify the requirements line in `lagrangian_cavae.sub` accordingly.

## 4. Outputs and Logging

* **Training Logs:** All logs are saved to the `trained_logs` directory. They are automatically organized into sub-folders based on the number of epochs run.
* **Checkpoints:** Upon a successful run, model checkpoints are saved to the `checkpoints` directory. A specific sub-folder (e.g., `pend-lag-cavae`) will be created for the experiment.