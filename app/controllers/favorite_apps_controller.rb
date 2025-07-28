class FavoriteAppsController < ApplicationController
  def index
    contents = @current_user.user_apps.includes(:app).order(:position).map do |user_app|
      { id: user_app.id, app_id: user_app.app.id, name: user_app.app.name, position: user_app.position }
    end

    render json: contents
  end

  def create
    @user_app = @current_user.user_apps.create!(app: App.find(favorite_app_params[:id]), position: favorite_app_params[:position])

    render json: @user_app
  end

  def update
    @user_app = @current_user.user_apps.find(params[:id])
    @user_app.update!(position: favorite_app_params[:position])

    render json: @user_app
  end

  private

  def favorite_app_params
    params.require(:app).permit(:id, :position)
  end
end
