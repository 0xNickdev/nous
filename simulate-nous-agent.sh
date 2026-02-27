#!/bin/bash

# Usage: ./simulate-nous-agent.sh [backdate_hours] [custom_message]
# Example: ./simulate-nous-agent.sh 4 "Updated agent stats"

BACKDATE_HOURS=${1:-0}
CUSTOM_MSG=${2:-""}

# Calculate fake commit date
if [ "$BACKDATE_HOURS" -gt 0 ]; then
  FAKE_DATE=$(date -v -${BACKDATE_HOURS}H '+%Y-%m-%dT%H:%M:%S')
else
  FAKE_DATE=$(date '+%Y-%m-%dT%H:%M:%S')
fi

# Simulate agent activity: update stats in index.html (example)
if [ -f "index.html" ]; then
  RANDOM_INCR=$((RANDOM % 15 + 1))
  sed -i '' "s/com:847/com:$((847 + RANDOM_INCR))/g" index.html
  echo "NOUS Agent auto-update: increased commits by $RANDOM_INCR at $FAKE_DATE" >> agent-activity.log
fi

# Commit message
if [ -z "$CUSTOM_MSG" ]; then
  COMMIT_MSG="Automated sync by NOUS Agent: protocol stats & activity log updated at $FAKE_DATE"
else
  COMMIT_MSG="Automated sync by NOUS Agent: $CUSTOM_MSG at $FAKE_DATE"
fi

# Stage changes
git add .

# Commit with backdate if requested
if [ "$BACKDATE_HOURS" -gt 0 ]; then
  GIT_AUTHOR_DATE="$FAKE_DATE" GIT_COMMITTER_DATE="$FAKE_DATE" git commit -m "$COMMIT_MSG" --date="$FAKE_DATE"
else
  git commit -m "$COMMIT_MSG"
fi

# Push to remote
git push origin main

echo "Simulation complete. Check commit history on GitHub."
