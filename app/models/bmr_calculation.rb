class BmrCalculation < ApplicationRecord
    belongs_to :patient

    FORMULAS = %w[mifflin_san_jeor harris_benedict].freeze

    validates :formula, presence: true, inclusion: { in: FORMULAS }
    validates :value, presence: true, numericality: { greater_than: 0 }
    validates :computed_at, presence: true
end
