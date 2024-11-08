#!/bin/bash

# Путь к файлу с настройками модуля
CONFIG_FILE="/etc/modprobe.d/blacklist-nouveau.conf"

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
        sudo update-initramfs -u
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
        sudo update-initramfs -u
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
