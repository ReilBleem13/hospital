# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'BMI API', type: :request do
  path '/bmi' do
    get 'Рассчитать BMI' do
      tags 'BMI'
      description 'Рассчитывает индекс массы тела (BMI) через внешний API'
      
      parameter name: :weight, in: :query, type: :number, format: :float, 
        description: 'Вес в килограммах', required: true
      parameter name: :height, in: :query, type: :number, format: :float, 
        description: 'Рост в сантиметрах', required: true

      response '200', 'BMI рассчитан' do
        schema type: :object,
          properties: {
            bmi: { type: :number, format: :float, example: 23.44 },
            category: { type: :string, example: 'Normal weight' },
            status: { type: :string, example: 'success' }
          }

        run_test!
      end

      response '400', 'Недостаточно параметров' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'Both weight and height are required' }
          }

        run_test!
      end

      response '422', 'Неверные параметры' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'height must be greater than 0' }
          }

        run_test!
      end

      response '502', 'Ошибка внешнего API' do
        schema type: :object,
          properties: {
            error: { type: :string, example: 'BMI API returned status 500' }
          }

        run_test!
      end
    end
  end
end
