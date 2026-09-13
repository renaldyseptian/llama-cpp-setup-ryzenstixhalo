#!/bin/bash
# deploy-llama.sh — Full deploy: ROCm 10 + llama.cpp HIP build + server
# Run in a new LXD container with GPU passthrough
set -e

echo "=== ROCm 10 Install ==="
if [ ! -f /opt/rocm/core-10.0/bin/rocm-smi ]; then
  curl -fsSL https://repo.radeon.com/rocm/rocm.gpg.key | gpg --dearmor -o /etc/apt/keyrings/rocm.gpg
  echo 'deb [signed-by=/etc/apt/keyrings/rocm.gpg] https://stable.repo.amd.com/rocm/core/packages/ubuntu2404/ stable main' > /etc/apt/sources.list.d/rocm.list
  apt-get update && apt-get install -y amdrocm-base10.0 amdrocm-core10.0-gfx1151
fi

echo "=== Build llama.cpp HIP ==="
apt-get install -y git cmake build-essential
git clone --depth 1 https://github.com/ggml-org/llama.cpp /tmp/llama.cpp
cd /tmp/llama.cpp && mkdir -p build && cd build
cmake .. -DGGML_HIP=ON -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DAMDGPU_TARGETS=gfx1151
make -j$(nproc) llama-cli llama-server llama-bench
cp bin/* /usr/local/bin/

echo "=== ROCm Env ===\n"
echo 'export HSA_OVERRIDE_GFX_VERSION=11.5.1' > /etc/profile.d/rocm.sh
source /etc/profile.d/rocm.sh

echo "=== Download Model from HuggingFace ===\n"
MODEL_DIR=/models/Qwen3.6-35B-A3B-GGUF
MODEL_FILE=Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf
MODEL_URL="https://huggingface.co/bartowski/Qwen_Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf"

if [ ! -f $MODEL_DIR/$MODEL_FILE ]; then
  mkdir -p $MODEL_DIR
  echo "Downloading 21GB model (Q4_K_M)..."
  pip install -q huggingface-hub
  huggingface-cli download bartowski/Qwen_Qwen3.6-35B-A3B-GGUF Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf --local-dir $MODEL_DIR
  echo "Model downloaded: $(ls -lh $MODEL_DIR/$MODEL_FILE)"
else
  echo "Model already exists: $(ls -lh $MODEL_DIR/$MODEL_FILE)"
fi

echo "=== Start Server ===\n"
nohup /usr/local/bin/llama-server \
  -m $MODEL_DIR/$MODEL_FILE \
  --host 0.0.0.0 --port 8081 \
  -ngl 99 -fa 1 -t 32 \
  -c 655360 -np 10 \
  --no-kv-offload --poll 0 \
  --alias qwen3.6-35b \
  > /tmp/llama-server.log 2>&1 &

echo "=== Done ===\n"
echo "Server PID: $!"
echo "API: http://$(hostname -I | awk '{print $1}'):8081"
echo "Log: /tmp/llama-server.log"
