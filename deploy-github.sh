#!/bin/bash
# ============================================================
# 🚀 Auto Deploy GitHub (SSH) - Version PRO FIXED
# Projet  : bunker-web3
# Auteur  : Khalid Pro
# ============================================================

set -euo pipefail

# =====================
# CONFIGURATION
# =====================
GIT_USER="khalidPro2025"
REPO_NAME="bunker-web3"
BRANCH="main"

SSH_KEY="$HOME/.ssh/id_ed25519"
SSH_PUB="$HOME/.ssh/id_ed25519.pub"
REMOTE="git@github.com:${GIT_USER}/${REPO_NAME}.git"

echo ""
echo "============================================================"
echo "🚀 DEPLOY START - $REPO_NAME"
echo "============================================================"

# =====================
# 1. SSH KEY CHECK
# =====================
echo "[1/6] 🔐 Vérification clé SSH..."

if [[ ! -f "$SSH_KEY" ]]; then
    echo "[SSH] Génération nouvelle clé SSH..."
    ssh-keygen -t ed25519 -C "${GIT_USER}@github.com" -f "$SSH_KEY" -N ""
else
    echo "[SSH] Clé existante détectée"
fi

# =====================
# 2. SSH AGENT
# =====================
echo "[2/6] 🚀 Démarrage agent SSH..."
eval "$(ssh-agent -s)" >/dev/null
ssh-add "$SSH_KEY" >/dev/null 2>&1

# =====================
# 3. TEST SSH GITHUB (FIX IMPORTANT)
# =====================
echo "[3/6] 🔎 Test connexion GitHub..."

SSH_OUTPUT=$(ssh -T git@github.com 2>&1 || true)

if echo "$SSH_OUTPUT" | grep -qi "authenticated"; then
    echo "[OK] Connexion SSH GitHub validée"
else
    echo "[ERROR] Connexion échouée"
    echo ""
    echo "👉 Ajoute cette clé dans GitHub :"
    echo "--------------------------------------------------"
    cat "$SSH_PUB"
    echo "--------------------------------------------------"
    echo "https://github.com/settings/keys"
    exit 1
fi

# =====================
# 4. INIT GIT
# =====================
echo "[4/6] 📦 Vérification Git..."

if [ ! -d ".git" ]; then
    git init
    git branch -M "$BRANCH"
    echo "[GIT] Repository initialisé"
fi

# =====================
# 5. REMOTE CONFIG
# =====================
echo "[5/6] 🔗 Configuration remote..."

if git remote get-url origin >/dev/null 2>&1; then
    CURRENT_REMOTE=$(git remote get-url origin)
    if [[ "$CURRENT_REMOTE" != "$REMOTE" ]]; then
        git remote remove origin
        git remote add origin "$REMOTE"
        echo "[GIT] Remote mis à jour"
    else
        echo "[GIT] Remote déjà correct"
    fi
else
    git remote add origin "$REMOTE"
    echo "[GIT] Remote ajouté"
fi

# =====================
# 6. COMMIT + PUSH
# =====================
echo "[6/6] 📤 Commit & Push..."

git add .

if git diff --cached --quiet; then
    echo "[GIT] Aucun changement à envoyer"
else
    git commit -m "🚀 Deploy $REPO_NAME - $(date '+%Y-%m-%d %H:%M:%S')"
fi

git push -u origin "$BRANCH"

# =====================
# FIN
# =====================
echo ""
echo "============================================================"
echo "✅ DEPLOY SUCCESS"
echo "📦 Repo : $REPO_NAME"
echo "🌐 URL  : https://github.com/${GIT_USER}/${REPO_NAME}"
echo "🕒 Date : $(date)"
echo "============================================================"
