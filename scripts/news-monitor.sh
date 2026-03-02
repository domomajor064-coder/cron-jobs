#!/bin/bash
# OpenClaw News Monitor - Multi-source
# Runs daily via heartbeat
# Sends findings to Discord channel 1477869011692945418

CHANNEL_ID="1477869011692945418"
LOG_DIR="$HOME/clawd/logs/news-monitor"
DATA_DIR="$HOME/clawd/data/news-monitor"
DEDUPE_SCRIPT="$HOME/clawd/scripts/news-dedupe.py"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR" "$DATA_DIR"

echo "[$TIMESTAMP] Starting news monitor..." >> "$LOG_DIR/scan.log"

# Show stats
STATS=$(python3 "$DEDUPE_SCRIPT" stats 2>&1)
echo "[$TIMESTAMP] $STATS" >> "$LOG_DIR/scan.log"

# Note: Actual searches performed by agent via web_search tool
# This script handles post-processing and formatting

# Categories to track:
# 1. OpenClaw/AI agent news (GitHub, HN, Reddit, blogs)
# 2. Finance news (markets, economy, Fed)
# 3. Politics news (elections, policy, geopolitics)

echo "[$TIMESTAMP] News monitor ready" >> "$LOG_DIR/scan.log"