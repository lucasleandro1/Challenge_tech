module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!

      def sign_up
        user = User.new(email: params[:email], password: params[:password])

        if user.save
          render json: { token: user.generate_access_token! }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def sign_in
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          render json: { token: user.generate_access_token! }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end
    end
  end
end
