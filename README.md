# Hospital Management API

## Описание

API для управления больницей: пациенты, врачи, расчёт BMR (базовый метаболизм) и BMI (индекс массы тела).

---

## Быстрый старт

### Docker

- **Запуск контейнеров:**  
  ```bash
  rake docker:up
  ```
- **Остановка и удаление контейнеров:**  
  ```bash
  rake docker:down
  ```
- **Пересборка контейнеров:**  
  ```bash
  rake docker:rebuild
  ```

Если команда `rake` недоступна, используйте:

```bash
docker-compose -f docker-compose.yml up -d
```

---

## Документация

- **Swagger UI:**  
  [http://localhost:3000/api-docs.html](http://localhost:3000/api-docs.html) — интерактивная документация
- **OpenAPI спецификация:**  
  [YAML](http://localhost:3000/api-docs/v1/swagger.yaml)  
  [JSON](http://localhost:3000/api-docs/v1/swagger.json)

---

## Основные эндпоинты

### Пациенты

- **Список:**  
  `GET /patients`
- **Создать:**  
  `POST /patients`
- **Получить по ID:**  
  `GET /patients/{id}`
- **Обновить:**  
  `PATCH /patients/{id}`
- **Удалить:**  
  `DELETE /patients/{id}`
- **Рассчитать BMR:**  
  `POST /patients/{id}/bmr?formula=mifflin_san_jeor`
- **История BMR:**  
  `GET /patients/{id}/bmr_history`
- **Получить BMI:**  
  `GET /patients/{id}/bmi`

**Параметры фильтрации для списка:**
- `full_name`, `gender`, `start_age`, `end_age`, `min_height`, `max_height`, `min_weight`, `max_weight`, `doctor_id`, `limit`, `offset`

**Пример запроса:**
```bash
curl "http://localhost:3000/patients?gender=male&limit=10"
```

**Пример создания пациента:**
```json
{
  "patient": {
    "first_name": "Иван",
    "last_name": "Иванов",
    "middle_name": "Иванович",
    "birthday": "1990-01-01",
    "gender": "male",
    "height": 180,
    "weight": 75,
    "doctor_ids": [1, 2]
  }
}
```

---

### Врачи

- **Список:**  
  `GET /doctors?limit=10&offset=0`
- **Создать:**  
  `POST /doctors`
- **Получить по ID:**  
  `GET /doctors/{id}`
- **Обновить:**  
  `PATCH /doctors/{id}`
- **Удалить:**  
  `DELETE /doctors/{id}`

**Пример создания врача:**
```json
{
  "doctor": {
    "first_name": "Доктор Иван",
    "last_name": "Иванов",
    "middle_name": "Иванович"
  }
}
```

---

### BMI API

- **Рассчитать BMI:**  
  `GET /bmi?weight=70&height=180`

---

## Коды ответов

- `200` — Успешно
- `201` — Ресурс создан
- `400` — Неверный запрос
- `404` — Не найдено
- `422` — Ошибка валидации
- `500` — Внутренняя ошибка сервера
- `502` — Ошибка внешнего API

---

## Форматы данных

<details>
<summary>Пациент</summary>

```json
{
  "id": 1,
  "first_name": "Иван",
  "last_name": "Иванов",
  "middle_name": "Иванович",
  "birthday": "1990-01-01",
  "gender": "male",
  "height": 180,
  "weight": 75,
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```
</details>

<details>
<summary>Врач</summary>

```json
{
  "id": 1,
  "first_name": "Доктор Иван",
  "last_name": "Иванов",
  "middle_name": "Иванович",
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```
</details>

<details>
<summary>Расчет BMR</summary>

```json
{
  "patient_id": 1,
  "formula": "mifflin_san_jeor",
  "value": 1750.5,
  "computed_at": "2024-01-01T12:00:00Z"
}
```
</details>

<details>
<summary>BMI результат</summary>

```json
{
  "bmi": 23.44,
  "category": "Normal weight",
  "status": "success"
}
```
</details>

---

## Валидация

**Пациент:**
- `first_name`, `last_name`, `birthday`, `gender`, `height`, `weight` — обязательные
- `gender` — "male" или "female"
- `height`, `weight` — положительные числа
- `birthday` — не может быть в будущем
- Возраст ≤ 125 лет

**Врач:**
- `first_name`, `last_name` — обязательные
- ФИО должно быть уникальным

**BMR:**
- `formula` — "mifflin_san_jeor" или "harris_benedict"
- `value` — положительное число

---

## Примеры использования

**Создание пациента и расчет BMR:**
```bash
curl -X POST http://localhost:3000/patients \
  -H "Content-Type: application/json" \
  -d '{
    "patient": {
      "first_name": "Анна",
      "last_name": "Петрова",
      "birthday": "1995-05-15",
      "gender": "female",
      "height": 165,
      "weight": 60
    }
  }'

curl -X POST "http://localhost:3000/patients/1/bmr?formula=mifflin_san_jeor"
```

**Поиск пациентов:**
```bash
curl "http://localhost:3000/patients?gender=male&start_age=30"
curl "http://localhost:3000/patients?full_name=Иван"
```

**Расчет BMI:**
```bash
curl "http://localhost:3000/bmi?weight=75&height=180"
```

---

## Технические детали

- **Фреймворк:** Ruby on Rails 8.0
- **База данных:** PostgreSQL
- **API формат:** JSON
- **Документация:** OpenAPI 3.0.1
- **Внешние API:** [BMI Calculator API](https://bmicalculatorapi.vercel.app)
