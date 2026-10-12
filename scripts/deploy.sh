#!/usr/bin/env bash
# deploy.sh — сценарий доставки статического сайта на devops-vm
# Использование: ./scripts/deploy.sh [--dry-run]

set -euo pipefail

# --- Константы ---
REMOTE="devops.local"
REMOTE_DIR="/var/www/devops-site"
LOCAL_DIR="site"
CERT_FILE="$HOME/devops.crt"

# --- Параметры ---
DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
    echo "[DRY RUN] Никакие изменения не будут применены."
fi

# --- Проверки ---
# 1. Проверка наличия rsync
if ! command -v rsync &>/dev/null; then
    echo "ОШИБКА: rsync не установлен." >&2
    exit 1
fi

# 2. Проверка существования локального каталога
if [[ ! -d "$LOCAL_DIR" ]]; then
    echo "ОШИБКА: локальный каталог '$LOCAL_DIR' не найден." >&2
    exit 1
fi

# 3. Проверка SSH-подключения к серверу
if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "$REMOTE" true 2>/dev/null; then
    echo "ОШИБКА: не удалось подключиться к '$REMOTE' по SSH." >&2
    exit 1
fi

# 4. Проверка существования удалённого каталога
if ! ssh "$REMOTE" "test -d '$REMOTE_DIR'"; then
    echo "ОШИБКА: удалённый каталог '$REMOTE_DIR' не существует." >&2
    exit 1
fi

# 5. Проверка прав записи (создаём тестовый файл и удаляем)
if ! ssh "$REMOTE" "touch '$REMOTE_DIR/.deploy_test' && rm '$REMOTE_DIR/.deploy_test'"; then
    echo "ОШИБКА: нет прав на запись в '$REMOTE_DIR'." >&2
    exit 1
fi

# --- Синхронизация ---
echo "Синхронизация $LOCAL_DIR/ → $REMOTE:$REMOTE_DIR/"
rsync -avz --delete --chmod=D755,F644 $DRY_RUN "$LOCAL_DIR/" "$REMOTE:$REMOTE_DIR/"

# --- Проверка результата (только если не dry-run) ---
if [[ -z "$DRY_RUN" ]]; then
    echo ""
    echo "Проверка доступности сайта:"
    if command -v curl &>/dev/null && [[ -f "$CERT_FILE" ]]; then
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --cacert "$CERT_FILE" "https://devops.local/")
        echo "  HTTP-код главной страницы: $HTTP_CODE"
        if [[ "$HTTP_CODE" == "200" ]]; then
            echo "  ✓ Сайт доступен."
        else
            echo "  ✗ Сайт недоступен (код $HTTP_CODE)." >&2
            exit 1
        fi
    else
        echo "  (пропуск проверки curl: curl или сертификат не найдены)"
    fi
fi

echo ""
echo "Деплой завершён успешно."
