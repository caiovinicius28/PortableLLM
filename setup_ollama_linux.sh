#!/bin/sh

main() {

set -eu

status() { echo ">>> $*" >&2; }
error() { echo "ERROR: $*"; exit 1; }

# Limpeza de arquivos temporários
TEMP_DIR=$(mktemp -d)
cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

available() { command -v "$1" >/dev/null; }

require() {
    local MISSING=''
    for TOOL in "$@"; do
        if ! available "$TOOL"; then
            MISSING="$MISSING $TOOL"
        fi
    done
    echo "$MISSING"
}

OS="$(uname -s)"
[ "$OS" = "Linux" ] || error "Linux only"

ARCH=$(uname -m)
case "$ARCH" in
    x86_64) ARCH="amd64" ;;
    aarch64|arm64) ARCH="arm64" ;;
    *) error "Unsupported architecture: $ARCH" ;;
esac

VER_PARAM="${OLLAMA_VERSION:+?version=$OLLAMA_VERSION}"

NEEDS=$(require curl tar)
[ -n "$NEEDS" ] && error "Missing tools:$NEEDS"

# ======== DEFINIR DIRETÓRIOS ========
# SCRIPT_DIR será a raiz do pendrive (onde o setup está rodando)
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$ROOT_DIR/ollama"

status "Installing binaries to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"

# ======== DOWNLOAD E EXTRAÇÃO ========
download_and_extract() {
    local url_base="https://ollama.com/download"
    local filename="ollama-linux-${ARCH}"

    if curl --fail --silent --head --location "${url_base}/${filename}.tar.zst${VER_PARAM}" >/dev/null 2>&1; then
        status "Downloading ${filename}.tar.zst"
        curl --fail --show-error --location \
            "${url_base}/${filename}.tar.zst${VER_PARAM}" | \
            zstd -d | tar -xf - -C "$INSTALL_DIR"
    else
        status "Downloading ${filename}.tgz"
        curl --fail --show-error --location \
            "${url_base}/${filename}.tgz${VER_PARAM}" | \
            tar -xzf - -C "$INSTALL_DIR"
    fi
}

download_and_extract

# ======== SCRIPT DO SERVIDOR (RAIZ) ========
status "Creating portable server launcher in root..."

cat <<EOF > "$ROOT_DIR/run.sh"
#!/bin/sh
DIR=\$(cd "\$(dirname "\$0")" && pwd)

export OLLAMA_MODELS="\$DIR/models"
export HOME="\$DIR"

mkdir -p "\$DIR/models"

# Executa o binário que está dentro da subpasta ollama/bin
"\$DIR/ollama/bin/ollama" serve
EOF

chmod +x "$ROOT_DIR/run.sh"

# ======== SCRIPT DO CLI (RAIZ) ========
status "Creating CLI launcher in root..."

cat <<EOF > "$ROOT_DIR/ollama-cli.sh"
#!/bin/sh
DIR=\$(cd "\$(dirname "\$0")" && pwd)

export OLLAMA_MODELS="\$DIR/models"
export HOME="\$DIR"

# Executa o binário correto passando todos os argumentos (\$@)
"\$DIR/ollama/bin/ollama" "\$@"
EOF

chmod +x "$ROOT_DIR/ollama-cli.sh"

status "Install complete!"
status "Your portable AI is ready at: $ROOT_DIR"
status "1. Run server: ./run.sh"
status "2. Use CLI:    ./ollama-cli.sh run llama3"

}

main
