module Api
    module V1
        class AppController < ApplicationController
            def index
                applications = App.order('created_at DESC')
                render json: {data:applications}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
            end

            def create
                app = App.new(app_params)
                app.save
                render json: {data:app}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
            end

            private
            def app_params
                params.require(:app).permit(:name)
            end
        end
    end 
end