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

echo "=== ROCm Env ==="
echo 'export HSA_OVERRIDE_GFX_VERSION=11.5.1' > /etc/profile.d/rocm.sh
source /etc/profile.d/rocm.sh

echo "=== Done ==="
echo "Run: nohup /usr/local/bin/llama-server \\"
echo "  -m /models/<model.gguf> --host 0.0.0.0 --port 8081 -ngl 99 -fa 1 -t 32 \\"
echo "  -c 655360 -np 10 --no-kv-offload --poll 0 --alias qwen3.6-35b \\"
echo "  > /tmp/llama-server.log 2>&1 &"
