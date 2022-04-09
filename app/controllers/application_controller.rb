class ApplicationController < ActionController::API
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity

    def render_unprocessable_entity(exception)
      render json: { error: exception.message }, status: :unprocessable_entity
    end
    
    def not_found
      render json: {error:"Invalid Path"},status:  :not_found
    end   
end
