class Doctor < ApplicationRecord

    has_many :doctor_patients, dependent: :destroy
    has_many :patients, through: :doctor_patients

    validates :first_name, :last_name, presence: true

    validates :first_name, uniqueness: {scope: [:last_name, :middle_name],
        message: "Doctor already exists"}

end
