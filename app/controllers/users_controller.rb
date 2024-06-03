class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @user = User.new(user_params)
      if @user.save
        @user.send_activation_email
        flash[:info] = "Please check your email to activate your account."
        redirect_to root_path
      else
        render 'new'
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error "Failed to create user: #{e.message}"
    flash[:danger] = "An error occurred while creating the user. Please try again."
    render 'new'
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    ActiveRecord::Base.transaction do
      @user = User.find(params[:id])
      if @user.update(user_params)
        flash[:success] = "Profile updated"
        redirect_to @user
      else
        render 'edit'
      end
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error "Failed to update user: #{e.message}"
    flash[:danger] = "An error occurred while updating the user. Please try again."
    render 'edit'
  end

  def destroy
    ActiveRecord::Base.transaction do
      User.find(params[:id]).destroy
      flash[:success] = "User deleted"
      redirect_to users_url
    end
  rescue ActiveRecord::StatementInvalid => e
    Rails.logger.error "Failed to delete user: #{e.message}"
    flash[:danger] = "An error occurred while deleting the user. Please try again."
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # def logged_in_user
  #   unless logged_in?
  #     store_location
  #     flash[:danger] = "Please log in."
  #     redirect_to login_url
  #   end
  # end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end
