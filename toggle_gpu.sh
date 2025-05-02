#!/bin/bash

# Путь к файлу с настройками модуля
CONFIG_FILE="/etc/modprobe.d/blacklist-nouveau.conf"

# Проверка, существует ли файл
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Файл с настройками модуля не существует. Создаём файл..."
    sudo touch "$CONFIG_FILE"
    echo "Файл $CONFIG_FILE был создан."
fi

# Определение утилиты для обновления initramfs
if [ -f /etc/debian_version ]; then
    INITRAMFS_CMD="sudo update-initramfs -u"
elif [ -f /etc/fedora-release ]; then
    INITRAMFS_CMD="sudo dracut --force"
else
    echo "Неизвестная система. Не могу определить утилиту для обновления initramfs."
    exit 1
fi

# Проверка текущего статуса
if sudo grep -q "blacklist nouveau" "$CONFIG_FILE"; then
    echo "Сейчас видеокарта NVIDIA отключена."
    echo "Хотите включить видеокарту? (Y/n)"
    read -r answer
    answer=${answer:-y}  # Автоматически устанавливает y, если ничего не введено
    if [[ $answer == "y" ]]; then
        echo "Включение видеокарты NVIDIA..."
        echo "Удаление настроек блокировки..."
        sudo sed -i '/blacklist nouveau/d' "$CONFIG_FILE"
        sudo sed -i '/options nouveau modeset=0/d' "$CONFIG_FILE"
        echo "Обновление initramfs..."
        $INITRAMFS_CMD
        echo "Видеокарта NVIDIA включена."
        echo "Перезагрузить систему для применения изменений? (Y/n)"
        read -r reboot_answer
        reboot_answer=${reboot_answer:-y}  # Автоматически устанавливает y, если ничего не введено
        if [[ $reboot_answer == "y" ]]; then
            sudo reboot
        else
            echo "Вы можете перезагрузить систему позже для применения изменений."
        fi
    else
        echo "Операция отменена. Видеокарта остаётся отключенной."
    fi
else
    echo "Сейчас видеокарта NVIDIA включена."
    echo "Хотите отключить видеокарту? (Y/n)"
    read -r answer
    answer=${answer:-y}  # Автоматически устанавливает y, если ничего не введено
    if [[ $answer == "y" ]]; then
        echo "Отключение видеокарты NVIDIA..."
        echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee "$CONFIG_FILE" > /dev/null
        echo "Обновление initramfs..."
        $INITRAMFS_CMD
        echo "Видеокарта NVIDIA отключена."
        echo "Перезагрузить систему для применения изменений? (Y/n)"
        read -r reboot_answer
        reboot_answer=${reboot_answer:-y}  # Автоматически устанавливает y, если ничего не введено
        if [[ $reboot_answer == "y" ]]; then
            sudo reboot
        else
            echo "Вы можете перезагрузить систему позже для применения изменений."
        fi
    else
        echo "Операция отменена. Видеокарта остаётся включенной."
    fi
fi
