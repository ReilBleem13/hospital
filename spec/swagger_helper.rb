# frozen_string_literal: true

require 'rails/test_help'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Hospital Management API',
        version: 'v1',
        description: 'API для управления больницей - пациенты, врачи, расчеты BMR и BMI',
        contact: {
          name: 'Hospital API Support'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        schemas: {
          Patient: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              first_name: { type: 'string', example: 'Иван' },
              last_name: { type: 'string', example: 'Иванов' },
              middle_name: { type: 'string', example: 'Иванович', nullable: true },
              birthday: { type: 'string', format: 'date', example: '1990-01-01' },
              gender: { type: 'string', enum: ['male', 'female'], example: 'male' },
              height: { type: 'integer', example: 180 },
              weight: { type: 'integer', example: 75 },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['first_name', 'last_name', 'birthday', 'gender', 'height', 'weight']
          },
          Doctor: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              first_name: { type: 'string', example: 'Доктор Иван' },
              last_name: { type: 'string', example: 'Иванов' },
              middle_name: { type: 'string', example: 'Иванович', nullable: true },
              created_at: { type: 'string', format: 'date-time' },
              updated_at: { type: 'string', format: 'date-time' }
            },
            required: ['first_name', 'last_name']
          },
          BmrCalculation: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              patient_id: { type: 'integer' },
              formula: { type: 'string', enum: ['mifflin_san_jeor', 'harris_benedict'] },
              value: { type: 'number', format: 'float' },
              computed_at: { type: 'string', format: 'date-time' }
            },
            required: ['patient_id', 'formula', 'value', 'computed_at']
          },
          Error: {
            type: 'object',
            properties: {
              error: { type: 'string' },
              errors: { type: 'array', items: { type: 'string' } }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
