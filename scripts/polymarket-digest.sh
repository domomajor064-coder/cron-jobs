#!/bin/bash
# Polymarket Daily Digest Generator
# Runs at 8 AM and 8 PM EST

export PATH="$HOME/.bun/bin:$PATH"
DATA_DIR="$HOME/clawd/polymarket/data"
LOG_DIR="$HOME/clawd/polymarket/logs"
CHANNEL_ID="1477849428973846649"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Generating daily digest..." >> "$LOG_DIR/digest.log"

# Get top markets by volume
cd ~/clawd/skills/polymarket-odds
MARKETS=$(node polymarket.mjs events --tag=politics --limit=5 2>/dev/null | head -30)

# Format digest
DIGEST="📊 **Polymarket Daily Digest** ($(date '+%Y-%m-%d %H:%M'))

**Top Political Markets:**
$MARKETS

**Monitoring Status:**
• Paper Trading: ✅ Active
• Arbitrage Scan: Every 5 min
• Alerts: Edge >3%, Risk <50"

echo "$DIGEST" >> "$LOG_DIR/digest.log"
echo "$DIGEST"