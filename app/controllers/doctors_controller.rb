class DoctorsController < ApplicationController
  before_action :set_doctor, only: [:show, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def index
    limit = params[:limit].presence&.to_i || 10
    offset = params[:offset].presence&.to_i || 0
    limit = 20 if limit > 20
    offset = 0 if offset.negative?

    scoped = Doctor.order(created_at: :desc)

    total = scoped.count
    doctors = scoped.limit(limit).offset(offset)

    render json: { 
      data: doctors.as_json(only: [:id, :first_name, :last_name, :middle_name]),
      meta: {
        total: total,
        limit: limit,
        offset: offset
      }
    }, status: :ok
  end

  def show
    render json: { data: @doctor }, status: :ok
  end

  def create 
    @doctor = Doctor.new(doctor_params)
    if @doctor.save
      render json: {
        message: "Doctor successfully created",
        data: @doctor
      }, status: :created
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @doctor.update(doctor_params)
      render json: {
        message: "Doctor successfully updated",
        data: @doctor
      }, status: :ok
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @doctor.destroy
      render json: { message: "Doctor successfully deleted" }, status: :ok
    else
      render json: { errors: @doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private
    def set_doctor
      @doctor = Doctor.find(params[:id])
    end

    def doctor_params
      params.require(:doctor).permit(
        :first_name, :last_name, :middle_name)
    end

    def render_not_found
      render json: { error: "Doctor not found" }, status: :not_found
    end
end
