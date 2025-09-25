class Patient < ApplicationRecord
    has_many :doctor_patients, dependent: :destroy
    has_many :doctors, through: :doctor_patients
    has_many :bmr_calculations, dependent: :destroy

    validates :first_name, :last_name, :birthday, :gender, :height, :weight, presence: true

    validates :first_name, uniqueness: {scope: [:last_name, :middle_name, :birthday],
        message: "Patient already exists"}

    validates :height, numericality: {only_integer: true, greater_than: 0}
    validates :weight, numericality: {only_integer: true, greater_than: 0}
    validates :gender, inclusion: { in: %w[male female] }
    
    validate :validate_birthday_and_age

    def age
        calculate_age
    end

    private

    def validate_birthday_and_age
        return unless birthday.present?
        
        if birthday > Date.current
            errors.add(:birthday, "cannot be in the future")
            return
        end
        
        age = calculate_age
        if age > 125
            errors.add(:birthday, "age cannot exceed 125 years")
        end
    end

    def calculate_age
        return 0 unless birthday.present?
        ((Date.current - birthday) / 365.25).floor
    end

    scope :full_name_like, ->(q) {
        next all if q.blank?
        pattern = "%#{q.strip}%"
        if ActiveRecord::Base.connection.adapter_name.downcase.include?('postgres')
            where("first_name ILIKE :p OR last_name ILIKE :p OR middle_name ILIKE :p", p: pattern)
          else
            # SQLite/MySQL – регистронезависимо через LOWER
            where(
              "LOWER(first_name) LIKE LOWER(:p) OR LOWER(last_name) LIKE LOWER(:p) OR LOWER(middle_name) LIKE LOWER(:p)",
              p: pattern
            )
          end
    }

    scope :by_gender, ->(g) {
        g.present? ? where(gender: g) : all
    }

    scope :age_between, ->(start_age, end_age) {
        start_age = start_age.presence&.to_i
        end_age = end_age.presence&.to_i
        today = Date.current
        
        if start_age && end_age
            where(birthday: (today - end_age.years)..(today - start_age.years))
          elsif start_age
            where("birthday <= ?", today - start_age.years)
          elsif end_age
            where("birthday >= ?", today - end_age.years)
          else
            all
        end
    }
    
    scope :height_between, ->(min_h, max_h) {
        min_h = min_h.presence&.to_i
        max_h = max_h.presence&.to_i
        if min_h && max_h
            where(height: min_h..max_h)
        elsif min_h
            where("height >= ?", min_h)
        elsif max_h
            where("height <= ?", max_h)
        else
            all
        end 
    }

    scope :weight_between, ->(min_w, max_w) {
        min_w = min_w.presence&.to_i
        max_w = max_w.presence&.to_i
        if min_w && max_w
            where(weight: min_w..max_w)
        elsif min_w
            where("weight >= ?", min_w)
        elsif max_w
            where("weight <= ?", max_w)
        else
            all
        end
    }

    scope :by_doctor_id, ->(doctor_id){
        doctor_id.present? ? joins(:doctor_patients).where(doctor_patients: { doctor_id: doctor_id }) : all
    }

end
