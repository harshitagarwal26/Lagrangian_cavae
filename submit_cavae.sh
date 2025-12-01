#!/bin/bash

# Usage: ./submit_cavae.sh <trainer_script.py> [gpus] [max_epochs]
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <trainer_script.py> [gpus] [max_epochs]"
    exit 1
fi

TRAINER_SCRIPT="$1"
GPUS="$2"
MAX_EPOCHS="$3"

# Extract base pattern: e.g., cart-lag-cavae from cart_lag_cavae_trainer.py
BASENAME_PATTERN=$(basename "$TRAINER_SCRIPT" _trainer.py | tr '_' '-')

# Prepare command-line arguments, only if provided
GPUS_ARG=${GPUS:+--gpus $GPUS}
EPOCHS_ARG=${MAX_EPOCHS:+--max_epochs $MAX_EPOCHS}

# Generate unique filenames for temp files to avoid conflicts in parallel
RAND=$RANDOM
TMP_TRAIN_SH="run_training_${RAND}.sh"
TMP_SUB_FILE="cavae_${RAND}.sub"

# Create the output directory for logs if it doesn't exist
OUTDIR="training_logs/1000/${BASENAME_PATTERN}"
mkdir -p "$OUTDIR"

# Create custom run_training.sh
cat << EOF > "$TMP_TRAIN_SH"
#!/bin/bash
python Lagrangian_caVAE-main/examples/${TRAINER_SCRIPT} $GPUS_ARG $EPOCHS_ARG
EOF
chmod +x "$TMP_TRAIN_SH"

# Replace all relevant fields in cavae.sub, including output dirs/names
sed -e "s|executable = run_training.sh|executable = ${TMP_TRAIN_SH}|g" \
    -e "s|pend-lag-cavae|${BASENAME_PATTERN}|g" \
    -e "s|output = .*|output = training_logs/${BASENAME_PATTERN}/${MAX_EPOCHS}/train_out_\$(Cluster)_\$(Process).log|g" \
    -e "s|error = .*|error = training_logs/${BASENAME_PATTERN}/${MAX_EPOCHS}/train_\$(Cluster)_\$(Process).err|g" \
    -e "s|log = .*|log = training_logs/${BASENAME_PATTERN}/${MAX_EPOCHS}/train_\$(Cluster)_\$(Process).log|g" \
    lagrangian_cavae.sub > "$TMP_SUB_FILE"

# Submit the generated sub file
condor_submit "$TMP_SUB_FILE"

# (Optional) Sleep and then clean up if you want:
sleep 2
# rm -f "$TMP_TRAIN_SH" "$TMP_SUB_FILE"
rm -f "$TMP_SUB_FILE"

    # -e "s|transfer_output_remaps = .*|transfer_output_remaps = \"checkpoints = /home/hagarwal23/checkpoints/${BASENAME_PATTERN}/\"|g" \
