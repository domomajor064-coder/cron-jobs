# Cron Jobs

Automated monitoring and alerting scripts for OpenClaw, Polymarket, and news aggregation.

## Scripts

### Polymarket Trading
- `scripts/polymarket-scan.sh` — 5-minute arbitrage scanner (risk < 50 only)
- `scripts/polymarket-digest.sh` — Daily market digest (8 AM)
- `polymarket/config.json` — API keys and thresholds

### News Monitoring
- `scripts/news-monitor.sh` — Daily OpenClaw news aggregation
- `scripts/news-dedupe.py` — URL deduplication helper

### qmd (Semantic Search)
- `scripts/reindex-qmd.sh` — Auto-reindex memory files

## Cron Setup

```bash
# Polymarket 5-min scan
openclaw cron add --name "Polymarket 5min Scan" --every "5m" \
  --message "Run polymarket scan..." \
  --to "1477849428973846649" \
  --model "minimax/MiniMax-M2.1"

# Polymarket daily digest
openclaw cron add --name "Polymarket Daily Digest" --cron "0 8 * * *" \
  --message "Run polymarket daily digest..." \
  --to "1477849428973846649" \
  --model "minimax/MiniMax-M2.1"

# News monitor
openclaw cron add --name "OpenClaw News Monitor" --cron "0 8 * * *" \
  --message "Search for OpenClaw news..." \
  --to "1477869011692945418" \
  --model "minimax/MiniMax-M2.1"
```

## Model Strategy

- **MiniMax M2.1** — Routine scanning, monitoring (flat fee)
- **Kimi K2.5** — Deep analysis only when needed

## Channels

- `1477849428973846649` — Polymarket alerts & digest
- `1477869011692945418` — OpenClaw news

## Safety

- All Polymarket trading in **paper mode** (no real funds)
- Deduplication prevents duplicate alerts
- Risk filtering (alerts only for risk < 50)
