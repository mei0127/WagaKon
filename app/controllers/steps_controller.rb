class StepsController < ApplicationController
  before_action :require_user_logged_in
  before_action -> {user_author_match(params[:recipe_id])}
  
  def new
    @steps = (1..10).map do
      @recipe.steps.build
    end
  end

  def create
    @steps = []
    @form_steps = steps_params
    # 一括保存処理呼び出し
    if Step.bulk_create(@recipe, @steps, @form_steps)
      redirect_to preview_recipe_url(@recipe)
    else
      flash.now[:danger] = '内容に誤りがあります'
      render :new
    end
  end

  # def create
  #   @steps = []
  #   steps = steps_params
  #   steps.each do |step|
  #     if step[:content].present?
  #       @steps << @recipe.steps.build(step)
  #     end
  #   end
    
  #   if Step.bulk_save(@steps)
  #     redirect_to preview_recipe_url(@recipe)
  #   else
  #     flash.now[:danger] = '内容に誤りがあります'
  #     render :new
  #   end
  # end

  def edit
    @steps = @recipe.steps
    start = 1 + (@steps.present? ? @steps.last.id : 0)
    finish = start + 9 - @steps.size
    (start..finish).each do |i|
      @steps.build(id: i)
    end
  end
  
  def update
    @steps = @recipe.steps
    @form_steps = steps_params.is_a?(Array) ? steps_params : steps_params.values
    # 一括更新処理呼び出し
    if Step.bulk_update(@recipe, @form_steps)
      redirect_to recipe_url(@recipe)
    else
      flash.now[:danger] = '内容に誤りがあります'
      render :edit
    end
  end
  
  # def update
  #   @recipe.steps.destroy_all
  #   @steps = []
  #   steps = steps_params.is_a?(Array) ? steps_params : steps_params.values
  #   steps.each do |step|
  #     if step[:content].present?
  #       @steps << @recipe.steps.build(step)
  #     end
  #   end

  #   if Step.bulk_save(@steps)
  #     redirect_to recipe_url(@recipe)
  #   else
  #     flash.now[:danger] = '内容に誤りがあります'
  #     render :edit
  #   end
  # end
  
  private
  
  def steps_params
    params.permit(steps: [:number, :content])["steps"]
  end
end
