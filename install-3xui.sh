#!/bin/bash

# Функция для ожидания нажатия Enter
wait_for_enter() {
    echo -e "\nНажмите [Enter], чтобы продолжить..."
    read -r
}

# 1. Проверка на root
if [ "$EUID" -ne 0 ]; then
  echo "Ошибка: Запустите скрипт через sudo!"
  exit 1
fi

# 2. Проверка на уже установленную панель
if [ -f "/usr/local/x-ui/x-ui" ]; then
    clear
    echo "═══════════════════════════════════════════════════════════"
    echo "        3X-UI ПАНЕЛЬ УЖЕ УСТАНОВЛЕНА!                     "
    echo "═══════════════════════════════════════════════════════════"
    
    DB_PATH="/etc/x-ui/x-ui.db"
    if [ -f "$DB_PATH" ]; then
        USER_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='username';" 2>/dev/null)
        PASS_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='password';" 2>/dev/null)
        PORT_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='port';" 2>/dev/null)
        PATH_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='webBasePath';" 2>/dev/null)
        
        IP_EXT=$(curl -s ifconfig.me)
        PATH_CLEAN=$(echo "$PATH_EXT" | tr -d '"/')
        URL_EXT="https://${IP_EXT}:${PORT_EXT}/${PATH_CLEAN}/"
        
        echo -e "👤 Имя пользователя: \e[1m${USER_EXT}\e[0m"
        echo -e "🔑 Пароль:           \e[1m${PASS_EXT}\e[0m"
        echo -e "🔌 Порт:             \e[33m${PORT_EXT}\e[0m"
        echo -e "📁 Путь панели:      /${PATH_CLEAN}/"
        echo -e "🌐 Ссылка для входа: \e[32m${URL_EXT}\e[0m"
    else
        echo -e "\e[1;33mНе удалось получить данные для входа\e[0m"
    fi
    echo "═══════════════════════════════════════════════════════════"
    wait_for_enter
    exit 0
fi

# 3. Установка зависимостей
echo "--- Установка необходимых пакетов ---"
apt-get update && apt-get install -y expect qrencode curl sqlite3
sleep 1

echo "--- Запуск установки 3x-ui ---"
LOG_FILE="/tmp/3x_ui_install.log"
> "$LOG_FILE"

# 4. Установка через Expect
expect <<EOF | tee $LOG_FILE
set timeout -1
spawn bash -c "curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh | bash"

expect "Confirm the installation"
sleep 1
send "y\r"

expect "customize the Panel Port settings"
sleep 1
send "n\r"

expect "Choose an option"
sleep 1
send "2\r"

expect "Port to use for ACME"
sleep 1
send "\r"

expect eof
EOF

echo -e "\n--- Обработка данных ---"
sleep 2

# --- ИЗВЛЕЧЕНИЕ ДАННЫХ ---
DB_PATH="/etc/x-ui/x-ui.db"

if [ -f "$DB_PATH" ]; then
    USER_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='username';" 2>/dev/null)
    PASS_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='password';" 2>/dev/null)
    PORT_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='port';" 2>/dev/null)
    PATH_EXT=$(sqlite3 "$DB_PATH" "SELECT value FROM settings WHERE key='webBasePath';" 2>/dev/null)
fi

if [[ -z "$USER_EXT" ]] || [[ -z "$PASS_EXT" ]]; then
    USER_EXT=$(grep "Username:" $LOG_FILE | tail -1 | awk '{print $NF}' | tr -d '\r')
    PASS_EXT=$(grep "Password:" $LOG_FILE | tail -1 | awk '{print $NF}' | tr -d '\r')
fi

if [[ ! "$PORT_EXT" =~ ^[0-9]+$ ]]; then
    PORT_EXT=$(grep -E "Port:[[:space:]]+[0-9]+" $LOG_FILE | tail -1 | awk '{print $NF}' | tr -d '\r')
fi

if [[ -z "$PATH_EXT" ]]; then
    PATH_EXT=$(grep "WebBasePath:" $LOG_FILE | tail -1 | awk '{print $NF}' | tr -d '\r')
fi

IP_EXT=$(curl -s ifconfig.me)
PATH_CLEAN=$(echo "$PATH_EXT" | tr -d '"/' )
URL_EXT="https://${IP_EXT}:${PORT_EXT}/${PATH_CLEAN}/"

rm -f $LOG_FILE

clear
echo "═══════════════════════════════════════════════════════════"
echo "        УСТАНОВКА 3X-UI ЗАВЕРШЕНА!                         "
echo "═══════════════════════════════════════════════════════════"
echo -e "👤 Имя пользователя: \e[1m${USER_EXT}\e[0m"
echo -e "🔑 Пароль:           \e[1m${PASS_EXT}\e[0m"
echo -e "🔌 Порт:             \e[33m${PORT_EXT}\e[0m"
echo -e "📁 Путь панели:      /${PATH_CLEAN}/"
echo -e "🌐 Ссылка для входа: \e[32m${URL_EXT}\e[0m"
echo "═══════════════════════════════════════════════════════════"
echo -e "\e[1;33m⚠️  СОХРАНИТЕ ЭТИ ДАННЫЕ!\e[0m"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "ℹ️  Панель автоматически генерирует и продлевает сертификаты"
echo ""
echo -e "\e[1;32m✅ Установка завершена!\e[0m"
echo "═══════════════════════════════════════════════════════════"
echo ""

wait_for_enter
