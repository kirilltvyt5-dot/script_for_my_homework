#!/bin/bash

# Путь к файлу лога (в той же директории, что и скрипт)
LOG_FILE="mem.log"

# Порог потребления памяти (в процентах)
THRESHOLD=60

# Функция для записи в лог
log_event() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Функция для получения списка процессов с высоким потреблением памяти
find_high_mem_processes() {
    # Используем ps с выводом: PID, %MEM, CMD
    # Формат: %MEM — процент от общей RAM, CMD — команда
    ps aux --no-headers | awk '
    {
        # Пропускаем заголовки и процессы с нулевым %MEM
        if ($4 > '"$THRESHOLD"' && $4 != "0.0") {
            printf "PID: %s, %%MEM: %.1f%%, CMD: %s\n", $2, $4, substr($0, index($0, $11))
        }
    }'
}

echo "Мониторинг процессов, потребляющих > $THRESHOLD% RAM. Нажмите Ctrl+C для остановки."

# Создаём файл лога, если его нет
touch "$LOG_FILE"

while true; do
    # Получаем список процессов с высоким потреблением памяти
    high_mem_procs=$(find_high_mem_processes)

    # Если найдены процессы — записываем в лог
    if [ -n "$high_mem_procs" ]; then
        log_event "$high_mem_procs"
        echo "Найдены процессы с высоким потреблением памяти (> $THRESHOLD%):"
        echo "$high_mem_procs"
    else
        # Опционально: можно выводить статус, если нужно отслеживать
        # echo "Нет процессов с нагрузкой > $THRESHOLD% RAM"
    fi

    # Ждем 15 секунд перед следующей проверкой
    sleep 15
done
