#!/bin/bash

set -e  # Exit immediately if a command fails
set -o pipefail  # Catch errors in piped commands

echo "🚀 Setting up the machine with required tools and Kind cluster..."

# 🛠️ Update package lists and install required tools
echo "🔄 Updating package list..."
sudo apt update -y

echo "📦 Installing required packages..."
sudo apt install -y curl openssh-server vim net-tools docker.io

# 🐳 Ensure Docker is running
echo "🔧 Enabling and starting Docker service..."
sudo systemctl enable --now docker

# 🔥 Fix Docker.sock permission issue
echo "🔑 Adding current user to Docker group..."
sudo usermod -aG docker $USER
newgrp docker  # Apply group change immediately

# 📥 Install kubectl
echo "📥 Downloading and installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl  # Cleanup

# 🌱 Install Kind
echo "📥 Downloading and installing Kind..."
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# 🚀 Setting up Kind cluster
CONFIG_FILE="./config.yml"  # Config file should be in the same directory

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ Error: Kind config file '$CONFIG_FILE' not found!"
    exit 1
fi

echo "🌐 Creating Kind cluster using config file..."
kind create cluster --name my-kind-cluster --config "$CONFIG_FILE" --image kindest/node:v1.32.0@sha256:c48c62eac5da28cdadcf560d1d8616cfa6783b58f0d94cf63ad1bf49600cb027

echo "✅ Setup completed! Kind cluster is running with 1 control plane and 2 workers."
