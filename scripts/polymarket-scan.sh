#!/bin/bash
# Polymarket Monitor - Runs every 5 minutes
# SILENT - logs to files only, no Discord output
# Check logs manually: tail -f ~/clawd/polymarket/logs/scan.log

export PATH="$HOME/.bun/bin:$PATH:$HOME/.local/bin"
LOG_DIR="$HOME/clawd/polymarket/logs"
DATA_DIR="$HOME/clawd/polymarket/data"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

mkdir -p "$LOG_DIR" "$DATA_DIR"

echo "[$TIMESTAMP] Starting scan..." >> "$LOG_DIR/scan.log"

if [ ! -d "$HOME/clawd/skills/polymarket-arbitrage" ]; then
    echo "[$TIMESTAMP] ERROR: skill not found" >> "$LOG_DIR/scan.log"
    exit 0
fi

cd "$HOME/clawd/skills/polymarket-arbitrage"
python3 scripts/monitor.py --once --min-edge 3.0 --data-dir "$DATA_DIR" >> "$LOG_DIR/scan.log" 2>&1

if [ -f "$DATA_DIR/arbs.json" ]; then
    python3 << PYEOF >> "$LOG_DIR/scan.log"
import json
try:
    with open('$DATA_DIR/arbs.json') as f:
        data = json.load(f)
    opportunities = data.get('arbitrage_opportunities', [])
    low_risk = [arb for arb in opportunities if arb.get('risk_score', 100) < 50 and arb.get('net_profit_pct', 0) >= 3.0]
    high_risk = [arb for arb in opportunities if arb.get('risk_score', 100) >= 50]
    
    if low_risk:
        print(f"[$TIMESTAMP] FOUND: {len(low_risk)} low-risk opportunities")
        for arb in low_risk:
            print(f"  - {arb.get('market')}: {arb.get('net_profit_pct'):.1f}% profit, risk {arb.get('risk_score')}")
    if high_risk:
        print(f"[$TIMESTAMP] Filtered: {len(high_risk)} high-risk opportunities (not alerting)")
except Exception as e:
    print(f"[$TIMESTAMP] Error: {e}")
PYEOF
fi

echo "[$TIMESTAMP] Complete" >> "$LOG_DIR/scan.log"