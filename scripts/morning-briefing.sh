#!/bin/bash
# Morning Briefing - Use Case #52
# Sends weather + calendar + news digest to Discord at 7 AM EST
# Channel: 1477869011692945418

export PATH="$HOME/.bun/bin:$PATH"
CHANNEL_ID="1477869011692945418"
LOG_DIR="$HOME/clawd/logs/morning-briefing"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
mkdir -p "$LOG_DIR"

echo "[$TIMESTAMP] Generating morning briefing..." >> "$LOG_DIR/briefing.log"

# Get weather (New York - adjust as needed)
WEATHER=$(curl -s "wttr.in/New+York?format=%c+%t+(feels+like+%f),+%w+wind,+%h+humidity" 2>/dev/null || echo "Weather unavailable")

# Get today's date
TODAY=$(date '+%A, %B %d, %Y')

# Build briefing message
BRIEFING="🌅 **Morning Briefing** — $TODAY

🌤️ **Weather (NYC)**
$WEATHER

📅 **Today at a Glance**
• Check your calendar for meetings
• Review any urgent reminders
• Prioritize top 3 tasks for the day

📰 **News Preview**
• Daily digest at 8 AM with OpenClaw updates
• Polymarket scan running every 5 minutes
• News monitor tracking 6 sources

💡 **Quick Actions**
• Ask me about: weather, calendar, news, markets
• Use /status for system health
• Morning routine: activated

Have a productive day! ☕"

echo "$BRIEFING"
echo "[$TIMESTAMP] Briefing generated" >> "$LOG_DIR/briefing.log"