#!/bin/csh -f

# -------------------------------
# Check prerequisites
# -------------------------------
# Check that run_alphafold.py is in your PATH.
if ( ! `which run_alphafold.py` ) then
    echo "Error: run_alphafold.py is not found in your PATH. Please adjust your installation or PATH."
    exit 1
endif

# Check required environment variables.
if ( ! $?CONDA_PREFIX ) then
    echo "Error: CONDA_PREFIX is not set. Please activate your Conda environment."
    exit 1
endif

# -------------------------------
# Define variables
# -------------------------------
set APPDIR = "/home/user/Programs"          # Change as needed
set ALPHAFOLD3DIR = "$APPDIR/alphafold3"
set HMMER3_BINDIR = "$CONDA_PREFIX/bin"       # No trailing slash needed
set DB_DIR = "$ALPHAFOLD3DIR/public_databases"
set MODEL_DIR = "$ALPHAFOLD3DIR/models"
set WORK_DIR = `pwd`
set OUTPUT_DIR = "$WORK_DIR/output/"
set LOG_FILE = "$OUTPUT_DIR/af3_run.log"

# Create the output directory if it doesn't exist.
if ( ! -d "$OUTPUT_DIR" ) then
    mkdir -p "$OUTPUT_DIR"
endif

# Find the first JSON file in the current directory.
set JSON_FILE = `ls -1 *.json 2>/dev/null | head -n 1`
if ("$JSON_FILE" == "") then
    echo "Error: No JSON file found in $WORK_DIR. Exiting."
    exit 1
endif

# -------------------------------
# Run AlphaFold3
# -------------------------------
run_alphafold.py \
    --jackhmmer_binary_path="$HMMER3_BINDIR/jackhmmer" \
    --nhmmer_binary_path="$HMMER3_BINDIR/nhmmer" \
    --hmmalign_binary_path="$HMMER3_BINDIR/hmmalign" \
    --hmmsearch_binary_path="$HMMER3_BINDIR/hmmsearch" \
    --hmmbuild_binary_path="$HMMER3_BINDIR/hmmbuild" \
    --db_dir="$DB_DIR" \
    --model_dir="$MODEL_DIR" \
    --json_path="$WORK_DIR/$JSON_FILE" \
    --output_dir="$OUTPUT_DIR" \
    --buckets="256,512,768,1024,1280,1536,2048,2560,3072,3584,4096,4608,5120" |& tee -a "$LOG_FILE"
