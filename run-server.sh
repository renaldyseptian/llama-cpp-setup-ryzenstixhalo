#!/bin/bash
# run-server.sh — Start llama-server with Qwen3.6
export HSA_OVERRIDE_GFX_VERSION=11.5.1
nohup /usr/local/bin/llama-server \
  -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  --host 0.0.0.0 \
  --port 8081 \
  -ngl 99 -fa 1 -t 32 \
  -c 655360 -np 10 \
  --no-kv-offload --poll 0 \
  --alias qwen3.6-35b \
  > /tmp/llama-server.log 2>&1 &

echo "PID: $!"
echo "Log: /tmp/llama-server.log"
echo "API: http://$(hostname -I | awk '{print $1}'):8081"
