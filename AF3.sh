#!/bin/bash
# Exit immediately if a command exits with a non-zero status,
# treat unset variables as an error, and catch errors in piped commands.
set -euo pipefail

# -------------------------------
# Check prerequisites
# -------------------------------
# Make sure run_alphafold.py is in your PATH.
if ! command -v run_alphafold.py &>/dev/null; then
    echo "Error: run_alphafold.py is not found in your PATH. Please adjust your installation or PATH."
    exit 1
fi

# Make sure required environment variables are set.
: "${CONDA_PREFIX:?CONDA_PREFIX is not set. Please activate your Conda environment.}"

# -------------------------------
# Define variables
# -------------------------------
APPDIR="/home/user/Programs"         # Change as needed
ALPHAFOLD3DIR="${APPDIR}/alphafold3"
HMMER3_BINDIR="${CONDA_PREFIX}/bin"    # No trailing slash needed
DB_DIR="${ALPHAFOLD3DIR}/public_databases"
MODEL_DIR="${ALPHAFOLD3DIR}/models"
WORK_DIR="$(pwd)"
OUTPUT_DIR="${WORK_DIR}/output/"
LOG_FILE="${OUTPUT_DIR}/af3_run.log"

# Create the output directory if it does not exist.
mkdir -p "${OUTPUT_DIR}"

# Find the first JSON file in the current directory.
JSON_FILE=$(find . -maxdepth 1 -type f -name "*.json" | head -n 1 | sed 's|^\./||')
if [[ -z "${JSON_FILE}" ]]; then
    echo "Error: No JSON file found in $(pwd). Exiting."
    exit 1
fi

# -------------------------------
# Run AlphaFold3
# -------------------------------
run_alphafold.py \
    --jackhmmer_binary_path="${HMMER3_BINDIR}/jackhmmer" \
    --nhmmer_binary_path="${HMMER3_BINDIR}/nhmmer" \
    --hmmalign_binary_path="${HMMER3_BINDIR}/hmmalign" \
    --hmmsearch_binary_path="${HMMER3_BINDIR}/hmmsearch" \
    --hmmbuild_binary_path="${HMMER3_BINDIR}/hmmbuild" \
    --db_dir="${DB_DIR}" \
    --model_dir="${MODEL_DIR}" \
    --json_path="${WORK_DIR}/${JSON_FILE}" \
    --output_dir="${OUTPUT_DIR}" \
    --buckets="256,512,768,1024,1280,1536,2048,2560,3072,3584,4096,4608,5120" \
    2>&1 | tee -a "${LOG_FILE}"
