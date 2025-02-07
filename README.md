# Comprehensive Guide to Installing and Configuring AlphaFold 3 Using Conda Python 3.11 Environment
This guide details the necessary steps to install and configure AlphaFold 3 using a conda Python 3.11 environment. It includes the installation of Miniconda, environment creation, dependency installation, repository cloning, model configuration, and the preparation of an execution script. **It has been designed to rely solely on conda, without the need for installing any additional packages on the operating system, making it possible to perform this installation on any operating system that supports conda.** It is assumed that the appropriate graphics drivers are correctly installed for your Linux distribution.

## 0. Install Miniconda

Download and install Miniconda (for x86_64 architecture):

```bash
# Download the Miniconda installer
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh

# Run the installer
bash miniconda.sh

# Source the .bashrc to update your environment
source ~/.bashrc
```

> **Note:** During installation, you can accept the default settings or customize them according to your preferences.

---

## 1. Create a Conda Environment with Python 3.11

Create and activate a new conda environment named `Alphafold3` with Python 3.11:

```bash
# Create the environment
conda create -n Alphafold3 python=3.11

# Activate the environment
conda activate Alphafold3
```
> **Note:** During installation and execution of AlphaFold 3, the `AlphaFold3 Conda environment` needs to be activated.

---

## 2. Install Development Tools and Dependencies

Install the necessary development tools and dependencies within the conda environment, not on the system OS. Note that HMMER is installed using conda and does not require independent installation or compilation, although there may be tools that cannot be installed in this way.

```bash
# Install cmake, gcc, and gxx
conda install -c conda-forge cmake gcc gxx

# Install Boost for Python 3.11 and numpy
conda install -c conda-forge boost boost-cpp numpy  # Boost for Python 3.11

# Install compression libraries
conda install -c conda-forge bzip2 zstd

# Install git and zlib
conda install -c conda-forge git zlib

# Install HMMER
conda config --add channels bioconda
conda install -c bioconda hmmer

# Install and Upgrade pip within the Alphafold3 environment
conda install pip
pip install --upgrade pip  # Update pip (specific to the AF3 environment)
```

---

## 3. Install Required Python Packages with pip

Install the necessary Python packages using pip:

```bash
pip install absl-py==2.1.0 chex==0.1.87 dm-haiku==0.0.13 dm-tree==0.1.8 \
    filelock==3.16.1 "jax[cuda12]==0.4.34" jax-cuda12-pjrt==0.4.34 \
    jax-triton==0.2.0 jaxlib==0.4.34 jaxtyping==0.2.34 jmp==0.0.4 \
    ml-dtypes==0.5.0 numpy==2.1.3 nvidia-cublas-cu12==12.6.3.3 \
    nvidia-cuda-cupti-cu12==12.6.80 nvidia-cuda-nvcc-cu12==12.6.77 \
    nvidia-cuda-runtime-cu12==12.6.77 nvidia-cudnn-cu12==9.5.1.17 \
    nvidia-cufft-cu12==11.3.0.4 nvidia-cusolver-cu12==11.7.1.2 \
    nvidia-cusparse-cu12==12.5.4.2 nvidia-nccl-cu12==2.23.4 \
    nvidia-nvjitlink-cu12==12.6.77 opt-einsum==3.4.0 pillow==11.0.0 \
    rdkit==2024.3.5 scipy==1.14.1 tabulate==0.9.0 toolz==1.0.0 \
    tqdm==4.67.0 triton==3.1.0 typeguard==2.13.3 \
    typing-extensions==4.12.2 zstandard==0.23.0
```

---

## 4. Install AlphaFold 3

### 4.1 Clone the AlphaFold 3 Repository

Define your desired installation location and clone the official repository:

```bash
# Set the desired application directory
APPDIR="/home/user/Programs"  # Replace "/home/user/Programs" with your desired path

# Create the directory and navigate to it
mkdir -p $APPDIR
cd $APPDIR

# Clone the AlphaFold 3 repository
git clone https://github.com/google-deepmind/alphafold3.git

# Define the AlphaFold 3 directory variable
ALPHAFOLD3DIR="$APPDIR/alphafold3"
cd ${ALPHAFOLD3DIR}
```

### 4.2 Download the Databases

The `fetch_databases.sh` script downloads the necessary databases for AlphaFold 3. By default, it downloads them to your home directory. To change the download location to `${ALPHAFOLD3DIR}`, modify the script:

```bash
# Modify the download path in the script
sed -i 's|$HOME|$ALPHAFOLD3DIR|g' fetch_databases.sh

# Make the script executable
chmod +x fetch_databases.sh

# Run the script to download the databases
./fetch_databases.sh
```

> **Important:** Ensure you have sufficient disk space as the databases are quite large.

### 4.3 Obtain Model Parameters and Place Them in `models`

You need to request access to the AlphaFold 3 model parameters:

1. Complete the official request [form](https://forms.gle/svvpY4u2jsHEwWYS6) provided by the AlphaFold team. 
3. Access will be granted at Google DeepMind’s sole discretion. They aim to respond to requests within 2–3 business days. You may only use AlphaFold 3 model parameters if received directly from Google. Use is subject to these terms of use.
2. Once approved, you will receive a download link for `af3.bin.zst`.

Proceed to decompress and move the model files:

```bash
# Download the model parameters (replace <your_download_url>)
wget <your_download_url>

# Move the compressed model to the models directory
mv af3.bin.zst ${ALPHAFOLD3DIR}/models/

# Navigate to the models directory
cd ${ALPHAFOLD3DIR}/models/

# Decompress the model
unzstd af3.bin.zst
```

### 4.4 Install AlphaFold 3 from the Repository

There might be issues with `zlib` not linking correctly. Use the following environment variables to resolve this:

```bash
cd ${ALPHAFOLD3DIR}

# Export paths for zlib
export CXXFLAGS="-I$(dirname $(find ${CONDA_PREFIX} -name zlib.h | head -n 1))"
export LDFLAGS="-L$(dirname $(find ${CONDA_PREFIX} -name libz.so | head -n 1)) -lz"

# Install AlphaFold 3 without additional dependencies
python -m pip install --no-deps .
```

### 4.5 Build Additional Components

Compile the necessary components from the conda environment's `bin` directory:

```bash
cd ${CONDA_PREFIX}/bin

# Execute the build script
./build_data  # Execute
```

### 4.6 Test the Installation

Verify that the installation was successful by displaying the help message:

```bash
cd ${ALPHAFOLD3DIR}

# Display the help message
python run_alphafold.py --help
```

### 4.7 Make `run_alphafold.py` Executable from Anywhere

To run `run_alphafold.py` from any location, add the shebang line with the path to Python from your conda environment and make it executable:

```bash
# Add the shebang line to the script
sed -i '1s|^|#!'"$(which python)"'\n|' run_alphafold.py

# Make the script executable
chmod +x run_alphafold.py
```

Create a symbolic link to the script in your conda environment's `bin` directory:

```bash
ln -s ${PWD}/run_alphafold.py ${CONDA_PREFIX}/bin/run_alphafold.py
```

Now, when your environment is active, you can run `run_alphafold.py` from any location.

---

### 5. Create an Execution Script: `AF3_run.sh`

Once you have installed AlphaFold 3, go to your working directory and test the AlphaFold 3 run using, for example, the following input JSON file named `fold_input.json`:
```
{
  "name": "2PV7",
  "sequences": [
    {
      "protein": {
        "id": ["A", "B"],
        "sequence": "GMRESYANENQFGFKTINSDIHKIVIVGGYGKLGGLFARYLRASGYPISILDREDWAVAESILANADVVIVSVPINLTLETIERLKPYLTENMLLADLTSVKREPLAKMLEVHTGAVLGLHPMFGADIASMAKQVVVRCDGRFPERYEWLLEQIQIWGAKIYQTNATEHDHNMTYIQALRHFSTFANGLHLSKQPINLANLLALSSPIYRLELAMIGRLFAQDAELYADIIMDKSENLAVIETLKQTYDEALTFFENNDRQGFIDAFHKVRDWFGDYSEQFLKESRQLLQQANDLKQG"
      }
    }
  ],
  "modelSeeds": [1],
  "dialect": "alphafold3",
  "version": 1
}
```

Create a script called `AF3_run.sh` with the following content to facilitate running AlphaFold 3:

```bash
#!/bin/bash

APPDIR="/home/user/Programs"  # Replace with your actual path if different
ALPHAFOLD3DIR="$APPDIR/alphafold3"
#HMMER3_BINDIR="/usr/bin" # Path to HMMER binaries (**installed via OS package manager or specify your path**)
HMMER3_BINDIR="${CONDA_PREFIX}/bin/" # Path to Conda binarys (**installed via conda**)
DB_DIR="${ALPHAFOLD3DIR}/public_databases"
MODEL_DIR="${ALPHAFOLD3DIR}/models"
WORK_DIR=$(pwd)
OUTPUT_DIR="${WORK_DIR}/output/${BASE_NAME}"
LOG_FILE="${OUTPUT_DIR}/af3_run.log"
JSON_FILE=$(ls -1 *.json 2>/dev/null | head -n 1)

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
    --buckets="256,512,768,1024,1280,1536,2048,2560,3072,3584,4096,4608,5120"
```

Make the script executable:

```bash
chmod +x AF3_run.sh
```

Now, with your conda environment active and in the appropriate working directory, you can run AlphaFold 3 simply by executing:

```bash
./AF3_run.sh
```
## Additional Notes
- **Use the `AF3_run.sh`** script anywhere on the system.

    ```
        cp AF3_run.sh ${CONDA_PREFIX}/bin/
        chmod +x ${CONDA_PREFIX}/bin/AF3_run.sh
    ```
- **Hardware Requirements:** To run AlphaFold 3 on systems with limited resources, a minimum of an Amper NVIDIA GPU with 8 o 12 GB of VRAM. However, for optimal performance, it's recommended to use professional GPUs like the NVIDIA A100, H100 or high-end consumer GPUs such as the RTX 3090, 4090, or the latest 5090, as these offer superior memory and processing capabilities that significantly enhance the efficiency of running AlphaFold 3.
- **CUDA and NVIDIA Drivers:** Verify that you have the correct versions of CUDA and NVIDIA drivers that match the installed `nvidia` packages.
- **Disk Space:** The databases (627 GB), the models (2.1 GB), and the Conda environment (6.7 GB) require significant disk space. Make sure you have at least **800 GB of free space.**  
- **Updates and Support:** Regularly check the official [AlphaFold 3 repository](https://github.com/google-deepmind/alphafold3) for updates and potential changes to dependencies.

If you encounter any issues during the installation or execution process, feel free to ask for additional assistance.
## **Acknowledgment:**  
> This work was inspired by the [Alphafold3-Fedora-install](https://github.com/ullahsamee/Alphafold3-Fedora-install) repository by [ullahsamee](https://github.com/ullahsamee/Alphafold3-Fedora-install/commits?author=ullahsamee), originally developed for Fedora. We have adapted it to enhance its general applicability.  
