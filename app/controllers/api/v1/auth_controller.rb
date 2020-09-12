class Api::V1::AuthController < ApplicationController
    skip_before_action :authorized, only: [:create]
   
    def create
      #render json: {info: "Api::V1::AuthController:create reached"}
      
      @user = User.find_by(username: user_login_params[:username])
      #User#authenticate comes from BCrypt
      
      if @user && @user.authenticate(user_login_params[:password])
        # encode token comes from ApplicationController
        token = encode_token({ user_id: @user.id })
        render json: { status: 200, user: UserSerializer.new(@user), jwt: token }, status: :accepted
      else
        render json: { status: 401, statusmessage: 'Invalid username or password' }, status: :unauthorized
      end
    end
   
    private   
    def user_login_params
      # params { user: {username: 'Chandler Bing', password: 'hi' } }
      params.require(:user).permit(:username, :password)
    end
end