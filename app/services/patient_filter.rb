class PatientFilter
    def initialize(params)
      @params = params
    end
  
    def call
        pagination = pagination_params
    
        scoped = Patient
          .full_name_like(@params[:full_name])
          .by_gender(@params[:gender])
          .age_between(@params[:start_age], @params[:end_age])
          .height_between(@params[:min_height], @params[:max_height])
          .weight_between(@params[:min_weight], @params[:max_weight])
          .by_doctor_id(@params[:doctor_id])
          .order(created_at: :desc)
    
        {
          records: scoped.limit(pagination[:limit]).offset(pagination[:offset]),
          meta: {
            total: scoped.count,
            limit: pagination[:limit],
            offset: pagination[:offset]
          }
        }
      end

    private 

    def pagination_params
        limit = @params[:limit].to_i
        limit = 10 if limit <= 0
        limit = 20 if limit > 20

        offset = @params[:offset].to_i
        offset = 0 if offset < 0

        { limit: limit, offset: offset }
    end
end