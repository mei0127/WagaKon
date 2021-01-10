class UsersController < ApplicationController
  before_action :require_user_logged_in, except: [:new, :create]
  before_action :prepare_search, except: [:new]
  before_action :prepare_meals, except: [:new]
  before_action :accessable_user, only: :show
  before_action :correct_user, only: [:edit, :update, :destroy, :password_edit, :password_update, :friends, :favorite_recipes]
  
  def show
    if @user == current_user
      @recipes = @user.recipes
    else
      @recipes = @user.recipes.published
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      (0..6).each do |index|
        @user.meals.create(day_of_week: index)
      end
      login(@user.email, @user.password)
      flash[:success] = '登録しました'
      redirect_to root_url
    else
      flash.now[:danger] = '内容に誤りがあります'
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @user.authenticate(user_params[:password])
      if @user.update(user_params)
        flash[:success] = 'ユーザー情報が更新されました'
        redirect_to @user
      else
        flash.now[:danger] = '内容に誤りがあります'
        render :edit
      end
    else
      flash.now[:danger] = 'パスワードが間違っています'
      render :edit
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = 'アカウントが削除されました'
    redirect_to root_url
  end
  
  def password_edit
  end
  
  def password_update
    if @user.authenticate(password_params[:current_password])
      if @user.update(password_params.except(:current_password))
        flash[:success] = 'パスワードが更新されました'
        redirect_to @user
      else
        render :password_edit
      end
    else
      flash.now[:danger] = 'パスワードが間違っています'
      render :password_edit
    end
  end
  
  def friends
  end
  
  def search
    @user = current_user
    unless params[:search] == ""
      @result_user = User.search(params[:search])
    end
    render :friends
  end
  
  def favorite_recipes
    @favorite_recipes = @user.favorite_recipes & @user.accessable_recipes
  end

  private

  def user_params
    params.require(:user).permit(:name, :personal_id, :email, :image, :password, :password_confirmation)
  end
  
  def password_params
    params.permit(:current_password, :password, :password_confirmation)
  end
  
  def correct_user
    @user = User.find(params[:id])
    unless @user == current_user
      redirect_to root_url
    end
  end
  
  def accessable_user
    @user = User.find(params[:id])
    unless (@user == current_user) || current_user.approved_friends.include?(@user)
      redirect_to root_url
    end
  end
  
end
