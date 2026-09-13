# llama.cpp Setup — Ryzen Strix Halo

llama.cpp HIP deployment on AMD Ryzen AI MAX+ 395 (Strix Halo) with ROCm 10.

## Hardware
- **CPU**: AMD Ryzen AI MAX+ 395 (gfx1151)
- **GPU**: Radeon 8060S (unified memory 128GB)
- **ROCm**: 10.0

## Quick Deploy (auto: ROCm → build → download model → server)
```bash
git clone https://github.com/renaldyseptian/llama-cpp-setup-ryzenstixhalo.git
cd llama-cpp-setup-ryzenstixhalo
chmod +x deploy-llama.sh
./deploy-llama.sh
```

## Model Location & Download

**Default path (used by scripts):**
```
/models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf
```

**Manual download:**
```bash
mkdir -p /models/Qwen3.6-35B-A3B-GGUF
cd /models/Qwen3.6-35B-A3B-GGUF

# Option A: huggingface-cli
pip install huggingface-hub
huggingface-cli download bartowski/Qwen_Qwen3.6-35B-A3B-GGUF \
  Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf --local-dir .

# Option B: wget (direct)
wget -c https://huggingface.co/bartowski/Qwen_Qwen3.6-35B-A3B-GGUF/resolve/main/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf
```

## CLI Commands

### Run inference (one-shot)
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1

llama-cli \
  -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  --prompt "Halo, siapa kamu?" \
  --temp 0.7 -n-predict 256 -ngl 99 --flash-attn on -t 32
```

### Benchmark
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1

# Prefill speed
llama-bench -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  -ngl 99 -fa 1 -t 32 -p 512 -n 1

# Token generation speed
llama-bench -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  -ngl 99 -fa 1 -t 32 -p 1 -n 128

# Combined (prefill + generation)
llama-bench -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  -ngl 99 -fa 1 -t 32 -pg 128,256
```

### Start API Server
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1

llama-server \
  -m /models/Qwen3.6-35B-A3B-GGUF/Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf \
  --host 0.0.0.0 --port 8081 \
  -ngl 99 -fa 1 -t 32 \
  -c 655360 -np 10 \
  --no-kv-offload --poll 0 \
  --alias qwen3.6-35b
```

### Test API
```bash
curl http://<container-ip>:8081/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"qwen3.6-35b","messages":[{"role":"user","content":"Halo"}],"max_tokens":256}'
```

## Required ENV
```bash
export HSA_OVERRIDE_GFX_VERSION=11.5.1   # Wajib untuk GPU gfx1151
```

## Files
| File | Purpose |
|------|---------|
| `deploy-llama.sh` | Full auto-deploy: ROCm → build → download model → server |
| `run-server.sh` | Start server only (skip build) |
| `bench.sh` | Run benchmark suite |

## Performance
| Test | Speed |
|------|-------|
| Prefill (512 tok) | ~800 t/s |
| Token gen (1 user) | ~57 t/s |
| Token gen (10 concurrent) | ~36 t/s each |
| Total throughput | ~360 t/s |
| TTFT (short prompt) | ~66 ms |

## API
```
http://<container-ip>:8081/v1/chat/completions
```
