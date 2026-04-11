class ApplicationController < ActionController::API
  before_action :authenticate_user!

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    @current_user = User.where(access_token: token).first
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
  end
end
