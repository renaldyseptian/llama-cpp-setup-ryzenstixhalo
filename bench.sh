#!/bin/bash
# bench.sh — Run benchmark suite for Qwen3.6-35B-A3B
MODEL=/models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf
BENCH=/usr/local/bin/llama-bench
export HSA_OVERRIDE_GFX_VERSION=11.5.1

echo "=== Prefill Speed ==="
$BENCH -m $MODEL -ngl 99 -fa 1 -t 32 -p 32 -n 1 -o md 2>/dev/null | grep pp32
$BENCH -m $MODEL -ngl 99 -fa 1 -t 32 -p 512 -n 1 -o md 2>/dev/null | grep pp512

echo "=== Token Gen ==="
$BENCH -m $MODEL -ngl 99 -fa 1 -t 32 -p 1 -n 128 -o md 2>/dev/null | grep tg128

echo "=== Combined ==="
$BENCH -m $MODEL -ngl 99 -fa 1 -t 32 -pg 128,128 -o md 2>/dev/null | grep pp128
$BENCH -m $MODEL -ngl 99 -fa 1 -t 32 -pg 512,512 -o md 2>/dev/null | grep pp512
