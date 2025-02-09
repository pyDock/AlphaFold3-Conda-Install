#!/bin/csh

# Simula `set -euo pipefail`
onintr exit

# Definir variable con argumento o valor por defecto
if ($#argv >= 1) then
  set db_dir = "$1"
else
  set db_dir = "$AF3_DB/public_databases"
endif

# Verificar que wget, tar y zstd están instalados
foreach cmd (wget tar zstd)
  if (! `which $cmd > /dev/null 2>&1`) then
    echo "$cmd is not installed. Please install it."
  endif
end

echo "Fetching databases to $db_dir"
mkdir -p "$db_dir"

set SOURCE = "https://storage.googleapis.com/alphafold-databases/v3.0"

echo "Start Fetching and Untarring 'pdb_2022_09_28_mmcif_files.tar'"
wget --quiet --output-document=- \
    "$SOURCE/pdb_2022_09_28_mmcif_files.tar.zst" | \
    tar --no-same-owner --no-same-permissions \
    --use-compress-program=zstd -xf - --directory="$db_dir" &

# Lista de archivos
set FILES = ("mgy_clusters_2022_05.fa" \
             "bfd-first_non_consensus_sequences.fasta" \
             "uniref90_2022_05.fa" "uniprot_all_2021_04.fa" \
             "pdb_seqres_2022_09_28.fasta" \
             "rnacentral_active_seq_id_90_cov_80_linclust.fasta" \
             "nt_rna_2023_02_23_clust_seq_id_90_cov_80_rep_seq.fasta" \
             "rfam_14_9_clust_seq_id_90_cov_80_rep_seq.fasta")

# Descargar cada archivo en paralelo
foreach NAME ($FILES)
  echo "Start Fetching '$NAME'"
  wget --quiet --output-document=- "$SOURCE/$NAME.zst" | \
      zstd --decompress > "$db_dir/$NAME" &
end

wait
echo "Complete"
