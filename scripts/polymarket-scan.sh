#!/bin/bash
# Polymarket Monitor - Runs every 5 minutes
# Uses MiniMax for scanning, alerts to Discord channel ONLY for risk < 50

export PATH="$HOME/.bun/bin:$PATH:$HOME/.local/bin"
CHANNEL_ID="1477849428973846649"
LOG_DIR="$HOME/clawd/polymarket/logs"
DATA_DIR="$HOME/clawd/polymarket/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR" "$DATA_DIR"

echo "[$TIMESTAMP] Starting Polymarket scan..." >> "$LOG_DIR/scan.log"

# Check if polymarket-arbitrage skill exists
if [ ! -d "$HOME/clawd/skills/polymarket-arbitrage" ]; then
    echo "[$TIMESTAMP] ERROR: polymarket-arbitrage skill not found" >> "$LOG_DIR/scan.log"
    exit 1
fi

cd "$HOME/clawd/skills/polymarket-arbitrage"

# Run single scan
python3 scripts/monitor.py --once --min-edge 3.0 --data-dir "$DATA_DIR" >> "$LOG_DIR/scan.log" 2>&1

# Check for new arbitrage opportunities and filter by risk
if [ -f "$DATA_DIR/arbs.json" ]; then
    # Filter for low-risk opportunities only (risk < 50)
    LOW_RISK_COUNT=$(python3 << PYEOF
import json
import sys
try:
    with open('$DATA_DIR/arbs.json') as f:
        data = json.load(f)
    opportunities = data.get('arbitrage_opportunities', [])
    low_risk = [arb for arb in opportunities if arb.get('risk_score', 100) < 50 and arb.get('net_profit_pct', 0) >= 3.0]
    print(len(low_risk))
except:
    print(0)
PYEOF
)
    
    echo "[$TIMESTAMP] Found $LOW_RISK_COUNT low-risk opportunities (risk < 50)" >> "$LOG_DIR/scan.log"
    
    if [ "$LOW_RISK_COUNT" -gt 0 ]; then
        # Generate Discord alert for low-risk opportunities only
        python3 << PYEOF > "$DATA_DIR/discord_alert.txt"
import json

try:
    with open('$DATA_DIR/arbs.json') as f:
        data = json.load(f)
    
    opportunities = data.get('arbitrage_opportunities', [])
    low_risk = [arb for arb in opportunities if arb.get('risk_score', 100) < 50 and arb.get('net_profit_pct', 0) >= 3.0]
    
    if low_risk:
        print("🎯 **Polymarket Arbitrage Alert**")
        print(f"📊 {len(low_risk)} opportunity(s) found (risk < 50)")
        print("")
        for arb in low_risk[:3]:
            market = arb.get('market', 'Unknown')
            profit = arb.get('net_profit_pct', 0)
            risk = arb.get('risk_score', 50)
            print(f"• **{market}**")
            print(f"  Profit: {profit:.1f}% | Risk: {risk}/100")
            print("")
        print("⏱️ Next scan: 5 minutes")
except Exception as e:
    print(f"Error: {e}")
PYEOF
        
        # Send to Discord using openclaw message
        if [ -f "$DATA_DIR/discord_alert.txt" ]; then
            MESSAGE=$(cat "$DATA_DIR/discord_alert.txt")
            if [ -n "$MESSAGE" ]; then
                # Log the alert
                echo "[$TIMESTAMP] ALERT: $MESSAGE" >> "$LOG_DIR/alerts.log"
                # Note: Discord sending happens via cron job or manual trigger
            fi
        fi
    fi
fi

echo "[$TIMESTAMP] Scan complete" >> "$LOG_DIR/scan.log"