class ArticlesController < ApplicationController
  before_action :require_user_logged_in, only: [:new, :create]
  before_action -> {user_author_match(params[:id])}, only: [:edit, :update, :destroy, :preview, :publish, :stop_publish]

  def show
    @article = Article.find(params[:id])
    if @article.status == "draft"
      redirect_to preview_article_url(@article)
    end
  end

  def new
    if logged_in?
      @article = current_user.articles.build
    end
  end

  def create
    @article = current_user.articles.build(article_params)
    if @article.save
      redirect_to new_article_material_path(@article)
    else
      flash.now[:danger] = '内容に誤りがあります'
      render :new
    end
  end

  def edit
  end
  
  def update
    if @article.update(article_params)
      redirect_to edit_article_materials_path(@article)
    else
      flash.now[:danger] = '内容に誤りがあります'
      render :edit
    end
  end
  
  def destroy
    @article.destroy
    flash[:success] = '正常に削除されました'
    redirect_to root_url
  end
  
  def preview
  end
  
  def publish
    @article.publishing
    redirect_to article_url(@article)
  end
  
  def stop_publish
    @article.drafting
    redirect_to draft_articles_user_url(@user)
  end
    
  def search
    redirect_to root_url if params[:search] == ""
    @articles = Article.published.search(params[:search])   
  end
    
  private

  def article_params
    params.require(:article).permit(:title, :image, :explanation)
  end
end
