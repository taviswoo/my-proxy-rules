#!/bin/sh

NODE_PORT=2222
SECRET_KEY=""
PROJECT_DIR="/opt/remnanode"
IMAGE="remnawave/node:latest"
RESTART="always"
NETWORK_MODE="host"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --node-port) NODE_PORT="$2"; shift 2;;
    --secret-key) SECRET_KEY="$2"; shift 2;;
    --project-dir) PROJECT_DIR="$2"; shift 2;;
    --image) IMAGE="$2"; shift 2;;
    --network-mode) NETWORK_MODE="$2"; shift 2;;
    --restart) RESTART="$2"; shift 2;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
done

if [ -z "$SECRET_KEY" ]; then
  echo "ERROR: --secret-key 必须提供"
  exit 1
fi

echo "[1/5] 安装依赖..."
apk add --no-cache docker curl

echo "[2/5] 启动 Docker..."
rc-update add docker
service docker start

echo "[3/5] 创建项目目录: $PROJECT_DIR"
mkdir -p "$PROJECT_DIR"

echo "[4/5] 写入 docker-compose.yml..."

cat > "$PROJECT_DIR/docker-compose.yml" <<EOF
version: "3.8"

services:
  remnanode:
    image: $IMAGE
    network_mode: $NETWORK_MODE
    restart: $RESTART
    environment:
      NODE_PORT: "$NODE_PORT"
      SECRET_KEY: $SECRET_KEY
    volumes:
      - $PROJECT_DIR/data:/app/data
    ports:
      - "$NODE_PORT:$NODE_PORT"
EOF

echo "[5/5] 启动 Remnanode..."
cd "$PROJECT_DIR"
docker compose pull
docker compose up -d

echo ""
echo "======================================"
echo " Remnanode 已成功安装在 Alpine 系统！"
echo " 端口: $NODE_PORT"
echo " 目录: $PROJECT_DIR"
echo " 镜像: $IMAGE"
echo "======================================"
