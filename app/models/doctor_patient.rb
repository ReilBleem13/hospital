class DoctorPatient < ApplicationRecord
  belongs_to :doctor
  belongs_to :patient

  validates :doctor_id, uniqueness: { scope: :patient_id }
end
