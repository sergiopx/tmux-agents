# Minimal shell config for VHS demo recording
DEMO_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
export PATH="$DEMO_DIR:$PATH"
export PS1="$ "
export TERM=xterm-256color
export TMUXAGENTS_DEMO_SESSIONS="research,coding,writing,analysis"
