require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  describe "#show" do
    context 'リクエストした記事のstatusが「公開」の場合' do
      before do
        @article = create(:article, status: "published")
        get :show, params: {id: @article.id}
      end
      it "200レスポンスが返る" do
        expect(response.status).to eq(200)
      end
      it "@articleにリクエストされた記事を割り当てる" do
        expect(assigns(:article)).to eq(@article)
      end
      it ':showテンプレートを表示する' do
        expect(response).to render_template :show
      end
    end
    context 'リクエストした記事のstatusが「非公開」の場合' do
      before do
        @article = create(:article, status: "draft")
        session[:user_id] = @article.user_id
        get :show, params: {id: @article.id}
      end
      it "302レスポンスが返る" do
        expect(response.status).to eq(302)
      end
      it "@articleにリクエストされた記事を割り当てる" do
        expect(assigns(:article)).to eq(@article)
      end
      it ':previewにリダイレクトする' do
        expect(response).to redirect_to preview_article_path(@article)
      end
    end
  end
end