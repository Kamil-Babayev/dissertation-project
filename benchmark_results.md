# Результаты нагрузочного тестирования: Монолит vs Микросервисы
*Дата проведения: Mon Apr 20 16:29:13 +04 2026*
*Тестовый сценарий: Имитация CPU-bound и Network-bound задач (обработка депозитов)*
---
## 1. Архитектура: Монолит
### Потребление ресурсов контейнерами (на пике нагрузки)

```text
NAME                               CPU %     MEM USAGE / LIMIT
dissertation-monolith-1            6.09%     13.2MiB / 512MiB
```
### Метрики производительности k6
```text
    http_req_duration..............: avg=76.22ms  min=70.41ms  med=75.51ms  max=96.61ms  p(90)=80.62ms  p(95)=82.83ms 
    http_req_failed................: 0.00%  0 out of 17551
    http_reqs......................: 17551  146.205557/s
    vus_max........................: 50     min=50         max=50
    data_received..................: 3.3 MB 27 kB/s
    data_sent......................: 3.6 MB 30 kB/s

```

## 2. Архитектура: Микросервисы (Без масштабирования)
### Потребление ресурсов контейнерами (на пике нагрузки)
```text
NAME                               CPU %     MEM USAGE / LIMIT
dissertation-gateway-1             18.29%    17.58MiB / 256MiB
dissertation-transaction-1         5.87%     12.84MiB / 256MiB
dissertation-validator-1           6.17%     12.81MiB / 256MiB
```
### Метрики производительности k6
```text
    http_req_duration..............: avg=75.39ms  min=70.15ms  med=74.82ms  max=125.79ms p(90)=78.69ms  p(95)=80.29ms 
    http_req_failed................: 0.00%  0 out of 17732
    http_reqs......................: 17732  147.739348/s
    vus_max........................: 50     min=50         max=50
    data_received..................: 3.3 MB 28 kB/s
    data_sent......................: 3.6 MB 30 kB/s

```

## 3. Архитектура: Микросервисы (Горизонтальное масштабирование)
### Потребление ресурсов контейнерами (на пике нагрузки)
```text
NAME                               CPU %     MEM USAGE / LIMIT
dissertation-gateway-1             13.74%    19.05MiB / 256MiB
dissertation-transaction-1         5.61%     14.79MiB / 256MiB
dissertation-validator-1           1.39%     13.06MiB / 256MiB
dissertation-validator-2           2.00%     7.645MiB / 256MiB
dissertation-validator-3           1.51%     7.129MiB / 256MiB
```
### Метрики производительности k6
```text
    http_req_duration..............: avg=75.16ms  min=64.79ms  med=74.44ms  max=161.76ms p(90)=78.18ms  p(95)=80.14ms 
    http_req_failed................: 0.00%  0 out of 17768
    http_reqs......................: 17768  147.951167/s
    vus_max........................: 50     min=50         max=50
    data_received..................: 3.3 MB 28 kB/s
    data_sent......................: 3.6 MB 30 kB/s
```
