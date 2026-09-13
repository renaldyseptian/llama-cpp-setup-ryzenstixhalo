# llama.cpp Setup — Ryzen Strix Halo

llama.cpp HIP deployment on AMD Ryzen AI MAX+ 395 (Strix Halo) with ROCm 10.

## Hardware
- **CPU**: AMD Ryzen AI MAX+ 395 (gfx1151)
- **GPU**: Radeon 8060S (unified memory 128GB)
- **ROCm**: 10.0

## Files
| File | Purpose |
|------|---------|
| `deploy-llama.sh` | Full deploy: ROCm 10 + llama.cpp HIP build + model download from HF + server |
| `run-server.sh` | Start llama-server with Qwen3.6 (skip build) |
| `bench.sh` | Benchmark suite |

## Usage
```bash
# Clone this repo on a new container, then:
chmod +x deploy-llama.sh
./deploy-llama.sh
# This will install ROCm 10, build llama.cpp HIP,
# download Qwen3.6-35B-A3B Q4_K_M from HuggingFace, and start the server.
```

## Model
- **Source**: [bartowski/Qwen_Qwen3.6-35B-A3B-GGUF](https://huggingface.co/bartowski/Qwen_Qwen3.6-35B-A3B-GGUF)
- **File**: `Qwen_Qwen3.6-35B-A3B-Q4_K_M.gguf` (21GB)
- **Quant**: Q4_K_M

## Performance (Qwen3.6-35B-A3B Q4_K_M)
| Test | Speed |
|------|-------|
| Prefill (512 tok) | ~800 t/s |
| Token gen (1 user) | ~57 t/s |
| Token gen (10 concurrent) | ~36 t/s each |
| Total throughput | ~360 t/s |

## API
```
http://<container-ip>:8081/v1/chat/completions
```

## Model Repository
Models available at `10.172.55.39:/models/llm/` (Ceph storage)
