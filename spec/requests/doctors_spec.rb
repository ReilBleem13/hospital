# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Doctors API', type: :request do
  path '/doctors' do
    get 'Получить список врачей' do
      tags 'Doctors'
      description 'Возвращает список врачей с поддержкой пагинации'
      
      parameter name: :limit, in: :query, type: :integer, description: 'Количество записей (максимум 20)'
      parameter name: :offset, in: :query, type: :integer, description: 'Смещение'

      response '200', 'Список врачей получен' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: { '$ref' => '#/components/schemas/Doctor' }
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

    post 'Создать врача' do
      tags 'Doctors'
      description 'Создает нового врача'
      
      parameter name: :doctor, in: :body, schema: {
        type: :object,
        properties: {
          doctor: {
            type: :object,
            properties: {
              first_name: { type: :string, example: 'Доктор Иван' },
              last_name: { type: :string, example: 'Иванов' },
              middle_name: { type: :string, example: 'Иванович' }
            },
            required: ['first_name', 'last_name']
          }
        }
      }

      response '201', 'Врач создан' do
        schema type: :object,
          properties: {
            message: { type: :string },
            data: { '$ref' => '#/components/schemas/Doctor' }
          }

        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end

  path '/doctors/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID врача'

    get 'Получить врача по ID' do
      tags 'Doctors'
      description 'Возвращает информацию о враче'

      response '200', 'Врач найден' do
        schema type: :object,
          properties: {
            data: { '$ref' => '#/components/schemas/Doctor' }
          }

        run_test!
      end

      response '404', 'Врач не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    patch 'Обновить врача' do
      tags 'Doctors'
      description 'Обновляет информацию о враче'
      
      parameter name: :doctor, in: :body, schema: {
        type: :object,
        properties: {
          doctor: {
            type: :object,
            properties: {
              first_name: { type: :string },
              last_name: { type: :string },
              middle_name: { type: :string }
            }
          }
        }
      }

      response '200', 'Врач обновлен' do
        schema type: :object,
          properties: {
            message: { type: :string },
            data: { '$ref' => '#/components/schemas/Doctor' }
          }

        run_test!
      end

      response '404', 'Врач не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end

      response '422', 'Ошибка валидации' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end

    delete 'Удалить врача' do
      tags 'Doctors'
      description 'Удаляет врача'

      response '200', 'Врач удален' do
        schema type: :object,
          properties: {
            message: { type: :string }
          }

        run_test!
      end

      response '404', 'Врач не найден' do
        schema '$ref' => '#/components/schemas/Error'
        run_test!
      end
    end
  end
end
