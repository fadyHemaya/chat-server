module Api
    module V1
        class AppController < ApplicationController
            def index
                applications = App.order('created_at DESC')
                render json: {data:applications}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
            end

            def show
                application = App.find_by(token: params[:app_token])
                if application
                    return render json: {data:application}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
                else
                    return render json: {data:"No App Found"},status:  :not_found
                end
            end

            def create
                if app_params[:name].nil? || app_params[:name].empty?
                    return render json: { error: "Invalid App Name" }, status: :unprocessable_entity
                end
                app = App.new(app_params)
                app.save
                redis = Redis.new(host: "redis")
                redis.set(app.token+"#chats_count",0)
                render json: {data:app}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
            end

            def update
                if app_params[:name].nil? || app_params[:name].empty?
                    return render json: { error: "Invalid App Name" }, status: :unprocessable_entity
                end
                application = App.find_by(token: params[:app_token])
                if application
                    application.update(name: app_params[:name])
                    return render json: {data:application}.to_json(:except => [:id, :created_at, :updated_at]),status: :ok
                else
                    return render json: {data:"No App Found"},status:  :not_found
                end
            end

            private
            def app_params
                params.require(:app).permit(:name)
            end
        end
    end 
end