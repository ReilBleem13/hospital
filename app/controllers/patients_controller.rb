class PatientsController < ApplicationController
  before_action :set_patient, only: [:show, :update, :destroy, :bmr, :bmr_history, :bmi]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActionController::ParameterMissing, with: :render_missing_params

  def index 
    patients = PatientFilter.new(params).call

    render json: {
      data: patients[:records].as_json(only: [:id, :first_name, :last_name, :middle_name, :birthday, :gender, :height, :weight]),
      meta: patients[:meta]
    }, status: :ok
  end

  def show
    render json: { data: @patient.as_json(include: :doctors) }, status: :ok
  end

  def create
    doctor_ids = patient_params[:doctor_ids] || []
    unless Doctor.where(id: doctor_ids).count == doctor_ids.size
      render json: { error: "One or more doctors not found" }, status: :unprocessable_entity
      return
    end

    @patient = Patient.new(patient_params)
    if @patient.save
      render json: {
        message: "Patient successfully created",
        data: @patient
      }, status: :created
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    if @patient.update(patient_params)
      render json: {
        message: "Patient successfully updated",
        data: @patient
      }, status: :ok
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @patient.destroy
      render json: { message: "Patient successfully deleted" }, status: :ok
    else
      render json: { errors: @patient.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def bmr
    formula = params.require(:formula)

    value = BmrCalculator.calculate!(
      formula: formula,
      sex: @patient.gender,
      weight_kg: @patient.weight.to_f,
      height_cm: @patient.height.to_f,
      age_years: @patient.age
    )

    record = @patient.bmr_calculations.create!(
      formula: formula,
      value: value,
      computed_at: Time.current
    )

    render json: {
      patient_id: @patient.id,
      formula: record.formula,
      value: record.value.to_f,
      computed_at: record.computed_at.iso8601
    }, status: :ok
  rescue BmrCalculator::UnsupportedFormulaError, BmrCalculator::InvalidParamsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  def bmr_history
    pagination = pagination_params
    scoped = @patient.bmr_calculations.order(computed_at: :desc)
    total = scoped.count
    bmrs = scoped.limit(pagination[:limit]).offset(pagination[:offset])

    render json: {
      patient_id: @patient.id,
      data: bmrs.as_json(only: [:id, :formula, :value, :computed_at]),
      meta: {
        total: total,
        limit: pagination[:limit],
        offset: pagination[:offset]
      }
    }, status: :ok
  end

  def bmi
    bmi_client = BmiClient.new
    result = bmi_client.fetch_bmi(@patient.weight, @patient.height)

    render json: result, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: "BMI API error: #{e.message}" }, status: :bad_gateway
  end

  private
    def set_patient
      @patient = Patient.find(params[:id])
    end

    def patient_params
      params.require(:patient).permit(
        :first_name, :last_name, :middle_name, :birthday, :gender, :height, :weight,
        doctor_ids: [])
    end

    def render_not_found
      render json: { error: "Patient not found" }, status: :not_found
    end
  
    def render_missing_params(exception)
      render json: { error: exception.message }, status: :bad_request
    end

    def pagination_params
      limit = params[:limit].to_i
      limit = 10 if limit <= 0
      limit = 20 if limit > 20
  
      offset = params[:offset].to_i
      offset = 0 if offset < 0
  
      { limit: limit, offset: offset }
    end
end
