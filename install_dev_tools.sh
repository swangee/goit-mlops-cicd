#!/usr/bin/env bash
set -euo pipefail

LOG_FILE="$(dirname "$0")/install.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

has() { command -v "$1" &>/dev/null; }

py_has() {
    python3 -c "import importlib.util,sys; sys.exit(0 if importlib.util.find_spec('$1') else 1)" 2>/dev/null
}

log "starting setup"

# OS check: debian/ubuntu only
if [ ! -r /etc/os-release ]; then
    log "ERROR: /etc/os-release not found, cannot determine OS"
    exit 1
fi
. /etc/os-release
case "${ID:-}:${ID_LIKE:-}" in
    debian:*|ubuntu:*|*:*debian*|*:*ubuntu*) log "OS ${PRETTY_NAME:-$ID} ok" ;;
    *)
        log "ERROR: OS '${PRETTY_NAME:-${ID:-unknown}}' is not supported, only ubuntu/debian are available"
        exit 1
        ;;
esac

# docker
if has docker; then
    log "docker ok"
else
    log "installing docker"
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends ca-certificates curl gnupg lsb-release
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --batch --yes -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    sudo apt-get update -qq
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# docker compose
if docker compose version &>/dev/null || has docker-compose; then
    log "compose ok"
else
    log "installing docker-compose"
    sudo curl -fsSL "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-$(uname -s)-$(uname -m)" \
        -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# python 3.9+
need_python=1
if has python3; then
    minor=$(python3 -c "import sys;print(sys.version_info.minor)")
    [ "$minor" -ge 9 ] && need_python=0
fi
if [ "$need_python" -eq 1 ]; then
    log "installing python"
    sudo apt-get update -qq
    sudo apt-get install -y python3 python3-venv python3-pip
else
    log "python $(python3 --version) ok"
fi

# pip
if ! python3 -m pip --version &>/dev/null; then
    log "installing pip"
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | python3
fi

python3 -m pip install --quiet --upgrade pip

# python packages
for pkg in torch torchvision pillow Django; do
    import_name=$(echo "$pkg" | tr '[:upper:]' '[:lower:]')
    [ "$import_name" = "pillow" ] && import_name=PIL
    if py_has "$import_name"; then
        log "$pkg already installed"
    else
        log "installing $pkg"
        python3 -m pip install --quiet "$pkg"
    fi
done

log "versions:"
log "  $(docker --version 2>/dev/null || echo 'docker missing')"
log "  $(docker compose version 2>/dev/null || docker-compose --version 2>/dev/null || echo 'compose missing')"
log "  $(python3 --version)"
log "  $(python3 -m pip --version)"
for p in torch torchvision PIL django; do
    v=$(python3 -c "import $p; print($p.__version__)" 2>/dev/null || echo "n/a")
    log "  $p $v"
done

log "done"
