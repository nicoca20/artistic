#!/bin/bash

DESIGN_NAME="sonic" # options: sonic, mlem
LOGO_IMAGE="examples/${DESIGN_NAME}/${DESIGN_NAME}_logo.png"
INPUT_GDS="../examples/${DESIGN_NAME}/${DESIGN_NAME}_vanilla.gds.gz"
TOP_METAL_LAYER=134
BOX_COORDS="112,112,178,178"
WORKDIR="meerkat_work"


# === DERIVED FILENAMES ===

TM_GDS="${DESIGN_NAME}_tm.gds.gz"
LOGO_GDS="${DESIGN_NAME}_logo.gds"
LOGO_MONO="${WORKDIR}/${DESIGN_NAME}_logo_mono.png"
LOGO_SVG="${WORKDIR}/${DESIGN_NAME}_logo.svg"
OUTPUT_GDS="${DESIGN_NAME}_chip.gds.gz"

rm -r "${WORKDIR}"
mkdir -p "${WORKDIR}"


cd "${WORKDIR}"
if [[ "$DESIGN_NAME" == "sonic" && ! -f "$INPUT_GDS" ]]; then
    wget https://github.com/user-attachments/files/21774926/croc_chip_fix_all.zip
    unzip croc_chip_fix_all.zip
    mv croc_chip_fix_all.gds "${INPUT_GDS}"
fi
cd ..

oseda python3 scripts/meerkat_interface.py \
    -i "${INPUT_GDS}" \
    -m "${TM_GDS}" \
    -g "${LOGO_GDS}" \
    -o "${OUTPUT_GDS}" \
    -w "${WORKDIR}" \
    -l 134

cd "${WORKDIR}"
oseda klayout -zz -rm ../scripts/export_top_metal.py
cd ..

cd "${WORKDIR}"
gzip -d "${TM_GDS}"
cd ..

convert "${LOGO_IMAGE}" -remap pattern:gray50 "${LOGO_MONO}"

oseda python3 scripts/meerkat.py \
    -m "${BOX_COORDS}" \
    -i "${LOGO_MONO}"\
    -g "${WORKDIR}/${DESIGN_NAME}_tm.gds" \
    -l 134 \
    -n "${DESIGN_NAME}" \
    -s "${LOGO_SVG}" \
    -o "${WORKDIR}/${LOGO_GDS}"

cd "${WORKDIR}"
oseda klayout -zz -rm ../scripts/merge_logo.py
cd ..

cd "${WORKDIR}"
gunzip -k "${OUTPUT_GDS}"
cd ..
