
## 8. Веб-сервер

- **Устанавливаемый пакет:** `nginx` (версия 1.24.0, Ubuntu)
- **Путь к конфигурации ресурса:** `/etc/nginx/sites-available/devops-site`
- **Каталог ресурса:** `/var/www/devops-site`, владелец `devops:devops`, права каталога `755`, файлов `644`
- **Сертификат:** `/etc/ssl/certs/devops.crt`, права `644`, владелец `root:root`
- **Закрытый ключ:** `/etc/ssl/private/devops.key`, права `600`, владелец `root:root`
- **Команда формирования сертификата:**
  ```bash
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/devops.key \
    -out /etc/ssl/certs/devops.crt \
    -subj "/CN=devops.local" \
    -addext "subjectAltName=DNS:devops.local"

---

### Шаг 3. Дополните скрипт audit.sh в WSL

```bash
cat >> scripts/audit.sh << 'EOF'

# [4] Веб-сервер
check "nginx service is active" \
  "systemctl is-active nginx"

check "nginx config is valid" \
  "sudo nginx -t"

check "certificate expires in more than 30 days" \
  "sudo openssl x509 -checkend 2592000 -noout -in /etc/ssl/certs/devops.crt"

check "no world-writable files in site dir and key permissions are 600" \
  "test -z \"\$(sudo find /var/www/devops-site -perm -o+w)\" && \
   test \"\$(sudo stat -c '%a' /etc/ssl/private/devops.key)\" = '600'"

## 8. Веб-сервер

- **Устанавливаемый пакет:** `nginx` (версия 1.24.0, Ubuntu)
- **Путь к конфигурации ресурса:** `/etc/nginx/sites-available/devops-site`
- **Каталог ресурса:** `/var/www/devops-site`, владелец `devops:devops`, права каталога `755`, файлов `644`
- **Сертификат:** `/etc/ssl/certs/devops.crt`, права `644`, владелец `root:root`
- **Закрытый ключ:** `/etc/ssl/private/devops.key`, права `600`, владелец `root:root`
- **Команда формирования сертификата:**
  ```bash
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/devops.key \
    -out /etc/ssl/certs/devops.crt \
    -subj "/CN=devops.local" \
    -addext "subjectAltName=DNS:devops.local"

---

### Шаг 7.2. Дополнение скрипта `scripts/audit.sh`

```bash
mkdir -p scripts
cat >> scripts/audit.sh << 'EOF'

# [4] Веб-сервер
check "nginx service is active" \
  "systemctl is-active nginx"

check "nginx config is valid" \
  "sudo nginx -t"

check "certificate expires in more than 30 days" \
  "sudo openssl x509 -checkend 2592000 -noout -in /etc/ssl/certs/devops.crt"

check "no world-writable files in site dir and key permissions are 600" \
  "test -z \"\$(sudo find /var/www/devops-site -perm -o+w)\" && \
   test \"\$(sudo stat -c '%a' /etc/ssl/private/devops.key)\" = '600'"
