class BmiController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :render_missing_params
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def index
    weight = params[:weight]
    height = params[:height]

    if weight.blank? || height.blank?
      return render json: { error: "Both weight and height are required" }, status: :bad_request
    end

    bmi_client = BmiClient.new
    result = bmi_client.fetch_bmi(weight, height)

    render json: result, status: :ok
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  rescue StandardError => e
    render json: { error: e.message }, status: :bad_gateway
  end

  private

  def render_missing_params(exception)
    render json: { error: exception.message }, status: :bad_request
  end

  def render_not_found
    render json: { error: "Resource not found" }, status: :not_found
  end
end