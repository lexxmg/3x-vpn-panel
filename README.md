# Устанавливаем 3x-ui панель для VLESS и сертификаты на 10 лет

## 📚 Описание

Этот скрипт автоматически устанавливает:
1. Панель **3X-UI** для управления VPN-протоколами.
2. Самоподписной **SSL-сертификат** сроком на **10 лет**.

## 🛠️ Что будет установлено?
- **OpenSSL**
- **QRencode**
- **3X-UI**

## 🚀 Как использовать?

### Вариант 1. Запуск скрипта (после отработки скрипт будет удален)
```bash
sudo apt update && sudo apt install -y git curl openssl qrencode systemd && sudo curl -o /tmp/install-3xui.sh https://raw.githubusercontent.com/lexxmg/3x-vpn-panel/main/install-3xui.sh && sudo chmod +x /tmp/install-3xui.sh && sudo /tmp/install-3xui.sh
```
### Вариант 2. Скрипт останется и его можно будет запустить ещё раз (например узнать логин пароль)
```bash
sudo apt update && sudo apt install -y git curl openssl qrencode systemd && sudo curl -O https://raw.githubusercontent.com/lexxmg/3x-vpn-panel/main/install-3xui.sh && sudo chmod +x install-3xui.sh && sudo ./install-3xui.sh
```
