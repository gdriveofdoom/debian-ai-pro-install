#!/bin/bash
set -e

echo "========== Starting AI Pro Setup =========="
sudo apt update && sudo apt upgrade -y

# Core dependencies
sudo apt install -y build-essential software-properties-common curl wget git ffmpeg unzip \
python3 python3-venv python3-pip nodejs npm lsb-release ca-certificates gnupg apt-transport-https

# --- NVIDIA / CUDA setup ---
if lspci | grep -iq nvidia; then
  echo "NVIDIA GPU detected → installing drivers + CUDA Toolkit"
  sudo apt install -y nvidia-driver firmware-misc-nonfree
  wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
  sudo dpkg -i cuda-keyring_1.1-1_all.deb
  sudo apt update && sudo apt install -y cuda-toolkit
else
  echo "No NVIDIA GPU found — skipping CUDA."
fi

# --- AI assistants ---
echo "Installing Ollama & LM Studio & GPT4All..."
curl -fsSL https://ollama.com/install.sh | sh
mkdir -p ~/AI && cd ~/AI
wget https://gpt4all.io/installers/gpt4all-installer-linux.run -O gpt4all.run
chmod +x gpt4all.run
wget https://releases.lmstudio.ai/linux/deb/latest -O lmstudio.deb
sudo apt install -y ./lmstudio.deb && rm lmstudio.deb

# --- Python AI libs ---
pip install --upgrade pip
pip install torch torchvision torchaudio xformers accelerate transformers diffusers \
huggingface_hub openai sentencepiece safetensors opencv-python pillow scikit-learn \
pandas numpy matplotlib seaborn jupyterlab voila nbconvert

# --- Hugging Face CLI ---
pip install "huggingface_hub[cli]"
huggingface-cli login || true

# --- ComfyUI (Stable Diffusion) ---
cd ~/AI
git clone https://github.com/lllyasviel/ComfyUI.git
python3 -m venv comfy_venv
source comfy_venv/bin/activate
pip install torch torchvision torchaudio xformers safetensors opencv-python
deactivate
echo "alias comfyui='cd ~/AI/ComfyUI && ./main.py'" >> ~/.bashrc

# --- Design / Editing tools ---
sudo apt install -y gimp krita inkscape darktable scribus imagemagick

# --- Video production ---
sudo apt install -y kdenlive blender shotcut ffmpeg obs-studio

# --- Publishing / Printing ---
sudo apt install -y calibre libreoffice pdfarranger ghostscript cups printer-driver-gutenprint
sudo systemctl enable --now cups

# --- Dev & Data tools ---
sudo apt install -y code neovim git-lfs
jupyter notebook --generate-config
mkdir -p ~/AI/notebooks

# --- VS Code Server ---
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER

# --- Cloud integration ---
sudo apt install -y nextcloud-desktop || true

# --- Aliases ---
{
  echo "alias aistudio='lmstudio'"
  echo "alias ollamaui='ollama run llama3'"
  echo "alias comfy='comfyui'"
  echo "alias aiworkshop='code-server --auth password'"
  echo "alias hfpush='huggingface-cli upload'"
  echo "alias notebooks='cd ~/AI/notebooks && jupyter lab &'"
} >> ~/.bashrc

echo "========== INSTALL COMPLETE =========="
echo "Run:  source ~/.bashrc"
echo "Use aliases: aistudio | comfy | notebooks | aiworkshop"
echo "Welcome to your Debian 13 AI Studio!"
