#!/bin/bash
set -e

REPORT="benchmark_results.md"
TEMP_LOG="k6_temp.log"

clear
echo "Начинаем тестирование. Результаты будут записаны в $REPORT..."

echo "# Результаты нагрузочного тестирования: Монолит vs Микросервисы" > "$REPORT"
echo "*Дата проведения: $(date)*" >> "$REPORT"
echo "*Тестовый сценарий: Имитация CPU-bound и Network-bound задач (обработка депозитов)*" >> "$REPORT"
echo "---" >> "$REPORT"

# --- ЭТАП 0: ПОДГОТОВКА СРЕДЫ ---
echo "Очистка предыдущих контейнеров..."
docker-compose down -v --remove-orphans

echo "Сборка и запуск базовой инфраструктуры (без масштабирования)..."
docker-compose up -d --build
echo "Ожидание инициализации сервисов (5 секунд)..."
sleep 5

# --- ЭТАП 1: ТЕСТ МОНОЛИТА ---
echo "Запуск теста: Монолит..."
echo "## 1. Архитектура: Монолит" >> "$REPORT"

docker-compose run --rm k6 run -e TARGET_URL=http://monolith:8080/deposit /scripts/load_test.js > "$TEMP_LOG" 2>&1 &
K6_PID=$!

echo "Ожидание 45 сек для выхода на пиковую нагрузку..."
sleep 45

echo "### Потребление ресурсов контейнерами (на пике нагрузки)" >> "$REPORT"
echo '
```text' >> "$REPORT"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep -E "NAME|monolith" >> "$REPORT"
echo '```' >> "$REPORT"

echo "Ожидание завершения теста..."
wait $K6_PID || true

echo "### Метрики производительности k6" >> "$REPORT"
echo '```text' >> "$REPORT"
grep -E "http_reqs|http_req_duration|http_req_waiting|http_req_connecting|http_req_failed|vus_max|data_received|data_sent" "$TEMP_LOG" >> "$REPORT"
echo '
```' >> "$REPORT"
echo "" >> "$REPORT"


# --- ЭТАП 2: ТЕСТ МИКРОСЕРВИСОВ (1 Реплика) ---
echo "Запуск теста: Микросервисы (1 реплика)..."
echo "## 2. Архитектура: Микросервисы (Без масштабирования)" >> "$REPORT"

docker-compose run --rm k6 run -e TARGET_URL=http://gateway:8080/deposit /scripts/load_test.js > "$TEMP_LOG" 2>&1 &
K6_PID=$!

echo "Ожидание 45 сек для выхода на пиковую нагрузку..."
sleep 45

echo "### Потребление ресурсов контейнерами (на пике нагрузки)" >> "$REPORT"
echo '```text' >> "$REPORT"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep -E "NAME|gateway|validator|transaction" | grep -v "k6" >> "$REPORT"
echo '```' >> "$REPORT"

echo "Ожидание завершения теста..."
wait $K6_PID || true

echo "### Метрики производительности k6" >> "$REPORT"
echo '```text' >> "$REPORT"
grep -E "http_reqs|http_req_duration|http_req_waiting|http_req_connecting|http_req_failed|vus_max|data_received|data_sent" "$TEMP_LOG" >> "$REPORT"
echo '
```' >> "$REPORT"
echo "" >> "$REPORT"


# --- ЭТАП 3: ТЕСТ МИКРОСЕРВИСОВ (3 Реплики) ---
echo "Масштабирование сервиса валидации (CPU-heavy) до 3 экземпляров..."
docker-compose up -d --scale validator=3
echo "Ожидание балансировки контейнеров (5 секунд)..."
sleep 5

echo "Запуск теста: Микросервисы (3 реплики)..."
echo "## 3. Архитектура: Микросервисы (Горизонтальное масштабирование)" >> "$REPORT"

docker-compose run --rm k6 run -e TARGET_URL=http://gateway:8080/deposit /scripts/load_test.js > "$TEMP_LOG" 2>&1 &
K6_PID=$!

echo "Ожидание 45 сек для выхода на пиковую нагрузку..."
sleep 45

echo "### Потребление ресурсов контейнерами (на пике нагрузки)" >> "$REPORT"
echo '```text' >> "$REPORT"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | grep -E "NAME|gateway|validator|transaction" | grep -v "k6" | sort >> "$REPORT"
echo '```' >> "$REPORT"

echo "Ожидание завершения теста..."
wait $K6_PID || true

echo "### Метрики производительности k6" >> "$REPORT"
echo '```text' >> "$REPORT"
grep -E "http_reqs|http_req_duration|http_req_waiting|http_req_connecting|http_req_failed|vus_max|data_received|data_sent" "$TEMP_LOG" >> "$REPORT"
echo '```' >> "$REPORT"


# --- ЭТАП 4: ОЧИСТКА ---
echo "Тестирование завершено. Очистка..."
docker-compose down
rm -f "$TEMP_LOG"

echo "Отчет успешно сгенерирован в файле $REPORT!"
