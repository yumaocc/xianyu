#!/bin/bash
cd XianyuAutoAgent
source venv/bin/activate
echo "启动后端 API 服务 (端口 5000)..."
python start_web.py
