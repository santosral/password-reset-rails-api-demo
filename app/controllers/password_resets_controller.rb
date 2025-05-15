class PasswordResetsController < ApplicationController
  def create
    service = RequestPasswordReset.call(email_address: user_params[:email_address])
    if service.success?
      render locals: { token: service.value }, status: :created
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  def update
    service = ChangePassword.call(
      raw_token: params[:token],
      new_password: reset_password_params[:password],
      new_password_confirmation: reset_password_params[:password_confirmation]
    )

    if service.success?
      render locals: { token: service.value }, status: :ok
    else
      render json: { errors: service.errors }, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.expect(user: [ :email_address ])
    end

    def reset_password_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
