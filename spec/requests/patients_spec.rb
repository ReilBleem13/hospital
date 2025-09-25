# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Patients API', type: :request do
  path '/patients' do
    get 'Получить список пациентов' do
      tags 'Patients'
      description 'Возвращает список пациентов с поддержкой фильтрации и пагинации'
      
      parameter name: :full_name, in: :query, type: :string, description: 'Поиск по ФИО'
      parameter name: :gender, in: :query, type: :string, enum: ['male', 'female'], description: 'Фильтр по полу'
      parameter name: :start_age, in: :query, type: :integer, description: 'Минимальный возраст'
      parameter name: :end_age, in: :query, type: :integer, description: 'Максимальный возраст'
      parameter name: :min_height, in: :query, type: :integer, description: 'Минимальный рост'
      parameter name: :max_height, in: :query, type: :integer, description: 'Максимальный рост'
      parameter name: :min_weight, in: :query, type: :integer, description: 'Минимальный вес'
      parameter name: :max_weight, in: :query, type: :integer, description: 'Максимальный вес'
      parameter name: :doctor_id, in: :query, type: :integer, description: 'ID врача'
      parameter name: :limit, in: :query, type: :integer, description: 'Количество записей (максимум 20)'
      parameter name: :offset, in: :query, type: :integer, description: 'Смещение'

      response '200', 'Список пациентов получен' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Patient' }
            },
            meta: {
              type: :object,
              properties: {
                total: { type: :integer },
                limit: { type: :integer },
                offset: { type: :integer }
              }
            }
          }

        run_test!
      end
    end

    post 'Создать пациента' do
      tags 'Patients'
      description 'Создает нового пациента'
      
      parameter name: :patient, in: :body, schema: {
        type: :object,
        properties: {
          patient: {
            type: :object,
            properties: {
              first_name: { type: :string, example: 'Иван' },
              last_name: { type: :string, example: 'Иванов' },
              middle_name: { type: :string, example: 'Иванович' },
              birthday: { type: :string, format: :date, example: '1990-01-01' },
              gender: { type: :string, enum: ['male', 'female'], example: 'male' },
              height: { type: :integer, example: 180 },
              weight: { type: :integer, example: 75 },
              doctor_ids: { type: :array, items: { type: :integer } }
            },
            required: ['first_name', 'last_name', 'birthday', 'gender', 'height', 'weight']
          }
        }
      }

      response '201', 'Пациент создан' do
        schema type: :object,
          properties: {
            message: { type: :string },
            data: { '$ref' => '#/components/schemas/Patient' }
          }

        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/patients/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID пациента'

    get 'Получить пациента по ID' do
      tags 'Patients'
      description 'Возвращает информацию о пациенте с его врачами'

      response '200', 'Пациент найден' do
        schema type: :object,
          properties: {
            data: {
              allOf: [
                { '$ref' => '#/components/schemas/Patient' },
                {
                  type: :object,
                  properties: {
                    doctors: {
                      type: :array,
                      items: { '$ref' => '#/components/schemas/Doctor' }
                    }
                  }
                }
              ]
            }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Обновить пациента' do
      tags 'Patients'
      description 'Обновляет информацию о пациенте'
      
      parameter name: :patient, in: :body, schema: {
        type: :object,
        properties: {
          patient: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              middle_name: { type: :string },
              birthday: { type: :string, format: :date },
              gender: { type: :string, enum: ['male', 'female'] },
              height: { type: :integer },
              weight: { type: :integer },
              doctor_ids: { type: :array, items: { type: :integer } }
            }
          }
        }
      }

      response '200', 'Пациент обновлен' do
        schema type: :object,
          properties: {
            message: { type: :string },
            data: { '$ref' => '#/components/schemas/Patient' }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete 'Удалить пациента' do
      tags 'Patients'
      description 'Удаляет пациента'

      response '200', 'Пациент удален' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/patients/{id}/bmr' do
    parameter name: :id, in: :path, type: :integer, description: 'ID пациента'

    post 'Рассчитать BMR для пациента' do
      tags 'Patients'
      description 'Рассчитывает базовый метаболизм для пациента по указанной формуле'
      
      parameter name: :formula, in: :query, type: :string, 
        enum: ['mifflin_san_jeor', 'harris_benedict'], 
        description: 'Формула для расчета BMR'

      response '200', 'BMR рассчитан' do
        schema type: :object,
          properties: {
            patient_id: { type: :integer },
            formula: { type: :string },
            value: { type: :number, format: :float },
            computed_at: { type: :string, format: :date_time }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/patients/{id}/bmr_history' do
    parameter name: :id, in: :path, type: :integer, description: 'ID пациента'

    get 'Получить историю расчетов BMR' do
      tags 'Patients'
      description 'Возвращает историю всех расчетов BMR для пациента'
      
      parameter name: :limit, in: :query, type: :integer, description: 'Количество записей'
      parameter name: :offset, in: :query, type: :integer, description: 'Смещение'

      response '200', 'История BMR получена' do
        schema type: :object,
          properties: {
            patient_id: { type: :integer },
            data: {
              type: :array,
              items: { '$ref' => '#/components/schemas/BmrCalculation' }
            },
            meta: {
              type: :object,
              properties: {
                total: { type: :integer },
                limit: { type: :integer },
                offset: { type: :integer }
              }
            }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/patients/{id}/bmi' do
    parameter name: :id, in: :path, type: :integer, description: 'ID пациента'

    get 'Получить BMI для пациента' do
      tags 'Patients'
      description 'Рассчитывает BMI для пациента через внешний API'

      response '200', 'BMI рассчитан' do
        schema type: :object,
          properties: {
            bmi: { type: :number, format: :float },
            category: { type: :string },
            status: { type: :string }
          }

        run_test!
      end

      response '404', 'Пациент не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '502', 'Ошибка внешнего API' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
