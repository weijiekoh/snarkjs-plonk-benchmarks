#!/bin/bash

cd "$(dirname "$0")"
cd ..
mkdir -p ./build/test

echo "Downloading ptau file"
wget -nc --quiet -O ./powersOfTau.ptau https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_12.ptau

echo "Compiling circuit"
npx circom ./circom/test/poseidonT2.circom -r ./build/test/poseidonT2.r1cs -w ./build/test/poseidonT2.wasm

#./build/test/poseidonT2 ./poseidonT2.input.json ./build/test/poseidonT2.wtns

echo "Calculating witness"
npx snarkjs wtns calculate ./build/test/poseidonT2.wasm ./poseidonT2.input.json ./build/test/poseidonT2.wtns

echo "Running Groth16 setup"
npx snarkjs groth16 setup ./build/test/poseidonT2.r1cs ./powersOfTau.ptau ./build/test/poseidonT2.groth16.zkey

echo "Generating Groth16 proof"
npx snarkjs groth16 prove ./build/test/poseidonT2.groth16.zkey ./build/test/poseidonT2.wtns ./groth16.proof.json ./groth16.public.json

echo "Running Plonk setup"
npx snarkjs plonk setup ./build/test/poseidonT2.r1cs powersOfTau.ptau build/test/poseidonT2.plonk.zkey

echo "Generating Plonk proof"
time npx snarkjs plonk prove ./build/test/poseidonT2.plonk.zkey ./build/test/poseidonT2.wtns ./build/test/poseidonT2.proof.json ./build/test/poseidonT2.public.json
