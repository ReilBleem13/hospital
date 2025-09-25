# Hospital Management API Documentation

## Обзор

API для управления больницей предоставляет возможности для работы с пациентами, врачами, расчетами BMR (базовый метаболизм) и BMI (индекс массы тела).

# Собрать Docker-контейнеры и запустить проект
rake docker:up

# Остановить все контейнеры и удалить их тома
rake docker:down

# Пересобрать контейнеры и запустить заново
rake docker:rebuild


## Доступ к документации

### Swagger UI
- **URL**: http://localhost:3000/api-docs.html
- **Описание**: Интерактивная документация с возможностью тестирования API

### OpenAPI спецификация
- **YAML**: http://localhost:3000/api-docs/v1/swagger.yaml
- **JSON**: http://localhost:3000/api-docs/v1/swagger.json

## Основные эндпоинты

### Пациенты (Patients)

#### Получить список пациентов
```
GET /patients
```

**Параметры фильтрации:**
- `full_name` - поиск по ФИО
- `gender` - фильтр по полу (male/female)
- `start_age`, `end_age` - диапазон возраста
- `min_height`, `max_height` - диапазон роста
- `min_weight`, `max_weight` - диапазон веса
- `doctor_id` - ID врача
- `limit` - количество записей (максимум 20)
- `offset` - смещение для пагинации

**Пример запроса:**
```bash
curl "http://localhost:3000/patients?gender=male&limit=10"
```

#### Создать пациента
```
POST /patients
```

**Тело запроса:**
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

#### Получить пациента по ID
```
GET /patients/{id}
```

#### Обновить пациента
```
PATCH /patients/{id}
```

#### Удалить пациента
```
DELETE /patients/{id}
```

#### Рассчитать BMR для пациента
```
POST /patients/{id}/bmr?formula=mifflin_san_jeor
```

**Доступные формулы:**
- `mifflin_san_jeor` - формула Миффлина-Сан Жеора
- `harris_benedict` - формула Харриса-Бенедикта

#### Получить историю BMR
```
GET /patients/{id}/bmr_history
```

#### Получить BMI для пациента
```
GET /patients/{id}/bmi
```

### Врачи (Doctors)

#### Получить список врачей
```
GET /doctors?limit=10&offset=0
```

#### Создать врача
```
POST /doctors
```

**Тело запроса:**
```json
{
  "doctor": {
    "first_name": "Доктор Иван",
    "last_name": "Иванов",
    "middle_name": "Иванович"
  }
}
```

#### Получить врача по ID
```
GET /doctors/{id}
```

#### Обновить врача
```
PATCH /doctors/{id}
```

#### Удалить врача
```
DELETE /doctors/{id}
```

### BMI API

#### Рассчитать BMI
```
GET /bmi?weight=70&height=180
```

## Коды ответов

- `200` - Успешный запрос
- `201` - Ресурс создан
- `400` - Неверный запрос
- `404` - Ресурс не найден
- `422` - Ошибка валидации
- `500` - Внутренняя ошибка сервера
- `502` - Ошибка внешнего API

## Форматы данных

### Пациент
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

### Врач
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

### Расчет BMR
```json
{
  "patient_id": 1,
  "formula": "mifflin_san_jeor",
  "value": 1750.5,
  "computed_at": "2024-01-01T12:00:00Z"
}
```

### BMI результат
```json
{
  "bmi": 23.44,
  "category": "Normal weight",
  "status": "success"
}
```

## Валидация

### Пациент
- `first_name`, `last_name`, `birthday`, `gender`, `height`, `weight` - обязательные поля
- `gender` - только "male" или "female"
- `height`, `weight` - положительные числа
- `birthday` - не может быть в будущем
- Возраст не может превышать 125 лет

### Врач
- `first_name`, `last_name` - обязательные поля
- Комбинация ФИО должна быть уникальной

### BMR
- `formula` - только "mifflin_san_jeor" или "harris_benedict"
- `value` - положительное число

## Примеры использования

### Создание пациента и расчет BMR
```bash
# Создать пациента
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

# Рассчитать BMR (используем ID из предыдущего ответа)
curl -X POST "http://localhost:3000/patients/1/bmr?formula=mifflin_san_jeor"
```

### Поиск пациентов
```bash
# Найти всех мужчин старше 30 лет
curl "http://localhost:3000/patients?gender=male&start_age=30"

# Найти пациентов по имени
curl "http://localhost:3000/patients?full_name=Иван"
```

### Расчет BMI
```bash
# Рассчитать BMI для роста 180 см и веса 75 кг
curl "http://localhost:3000/bmi?weight=75&height=180"
```

## Разработка

Для запуска сервера разработки:
```bash
rails server
```

Для запуска тестов:
```bash
rails test
```

## Технические детали

- **Фреймворк**: Ruby on Rails 8.0
- **База данных**: PostgreSQL
- **API формат**: JSON
- **Документация**: OpenAPI 3.0.1
- **Внешние API**: BMI Calculator API (https://bmicalculatorapi.vercel.app)
