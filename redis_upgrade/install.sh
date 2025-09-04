#!/bin/bash
set -euo pipefail

# 패키지가 위치한 디렉토리
PKG_DIR="/root/redis/redis8_offline"

echo "==== [1] Checking offline package directory ===="
if [[ ! -d "$PKG_DIR" ]]; then
  echo "Error: Directory $PKG_DIR not found!"
  exit 1
fi

cd "$PKG_DIR"
echo "Using offline RPM files from: $PKG_DIR"

# 네트워크 연결 차단 테스트
echo "==== [2] Verifying no network access ===="
if ping -c 1 8.8.8.8 &>/dev/null; then
  echo "Warning: Network appears to be active. This script is designed for offline use only."
fi

# dnf을 사용해 오프라인으로 설치
echo "==== [3] Installing packages (offline mode) ===="
sudo dnf install -y --disablerepo="*" --allowerasing ./*.rpm

echo "==== [4] Verifying redis installation ===="
if command -v redis-server >/dev/null 2>&1; then
  redis-server -v
else
  echo "Error: redis-server not found after installation!"
  exit 1
fi

echo "==== [5] Enabling and starting Redis service ===="
sudo systemctl enable --now redis
sudo systemctl status redis --no-pager || echo "Redis service failed to start. Check logs with: journalctl -u redis"

echo "==== [6] Completed offline installation successfully ===="

