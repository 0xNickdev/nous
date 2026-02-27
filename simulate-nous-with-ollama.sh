#!/bin/bash

# Usage: ./simulate-nous-with-ollama.sh [backdate_hours]
# Example: ./simulate-nous-with-ollama.sh 3

BACKDATE_HOURS=${1:-0}

# Calculate fake date (macOS compatible)
if [ "$BACKDATE_HOURS" -gt 0 ]; then
  FAKE_DATE=$(date -v -${BACKDATE_HOURS}H '+%Y-%m-%dT%H:%M:%S')
else
  FAKE_DATE=$(date '+%Y-%m-%dT%H:%M:%S')
fi

# Ollama prompt for smart commit message
PROMPT="You are NOUS Agent, an autonomous AI updating protocol stats. Generate a short, cyberpunk-style commit message describing these random changes to AXIOM-7 agent: +${RANDOM:0:2} commits, volume +$${RANDOM:0:2}k, score +${RANDOM:0:2}, days +${RANDOM:0:3}. Keep it under 80 chars. Example: 'NOUS Agent synced DeFi metrics: AXIOM-7 +8 commits, volume +$15k'"

# Call Ollama (llama3)
AI_MSG=$(ollama run llama3 "$PROMPT" 2>/dev/null | head -n 1 | sed 's/^[ \t]*//;s/[ \t]*$//')

# Fallback if Ollama fails
if [ -z "$AI_MSG" ]; then
  RANDOM_INCR=$((RANDOM % 15 + 1))
  AI_MSG="Automated sync by NOUS Agent: AXIOM-7 stats updated (+$RANDOM_INCR commits) at $FAKE_DATE"
fi

COMMIT_MSG="$AI_MSG at $FAKE_DATE"

# Changes to index.html (update AXIOM-7 stats)
if [ -f "index.html" ]; then
  COM_INCR=$((RANDOM % 15 + 5))
  VOL_INCR=$((RANDOM % 30 + 10))
  SC_INCR=$((RANDOM % 5 + 1))
  DAYS_INCR=$((RANDOM % 15 + 5))

  sed -i '' "s/com:[0-9]*/com:$((847 + COM_INCR))/g" index.html
  sed -i '' "s/vol:'\$[0-9]*k'/vol:'\$$((142 + VOL_INCR))k'/g" index.html
  sed -i '' "s/sc:[0-9]*/sc:$((94 + SC_INCR))/g" index.html
  sed -i '' "s/days:[0-9]*/days:$((62 + DAYS_INCR))/g" index.html

  echo "NOUS Agent update at $FAKE_DATE: AXIOM-7 +$COM_INCR commits, +$VOL_INCR k vol, +$SC_INCR score, +$DAYS_INCR days" >> agent-activity.log
fi

# Stage
git add .

# Commit with backdate
if [ "$BACKDATE_HOURS" -gt 0 ]; then
  GIT_AUTHOR_DATE="$FAKE_DATE" GIT_COMMITTER_DATE="$FAKE_DATE" git commit -m "$COMMIT_MSG" --date="$FAKE_DATE"
else
  git commit -m "$COMMIT_MSG"
fi

# Push
git push origin main --force-with-lease || git push origin main --force

echo "Simulation with Ollama complete."
echo "Commit message: $COMMIT_MSG"
echo "Check: https://github.com/0xNickdev/nous/commits/main"
