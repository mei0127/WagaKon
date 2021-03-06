class Recipe < ApplicationRecord
  mount_uploader :image, ImageUploader

  # レシピのタイトル、説明文必須
  validates :title, presence: true, length: { maximum: 20 }, lt4bytes: true
  validates :explanation, presence: true, length: { maximum: 60 }, lt4bytes: true
  validates :size, length: { maximum: 10 }
  validates :homepage, url: { allow_blank: true }
  validates :status, presence: true

  # statusカラム設定
  enum status: { draft: 0, published: 1 }

  belongs_to :user
  has_one :feature, dependent: :destroy
  accepts_nested_attributes_for :feature
  has_many :ingredients, dependent: :destroy
  has_many :steps, dependent: :destroy
  has_many :bookmarks, dependent: :destroy
  has_many :menus, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }

  # レシピの変更後属性を割り当て
  def replace_attributes(recipe_params)
    assign_attributes(recipe_params.except(:remove_img))
    remove_image! if recipe_params[:remove_img] == '1'
  end

  # レシピの公開、非公開
  def publishing
    update(status: 1)
  end

  def drafting
    update(status: 0)
  end

  def draft?
    status == 'draft'
  end

  # レシピをお気に入りの多い順に並べ替え
  def self.sort_likes
    Recipe.recent.includes(:bookmarks).sort { |a, b| b.bookmarks.size <=> a.bookmarks.size }
  end

  # レシピキーワード検索
  def self.keyword_search(search)
    keywords = search.split(/[[:blank:]]+/)
    if keywords.empty?
      false
    else
      recipes = Recipe
      keywords.each do |keyword|
        recipes = recipes.where(['title LIKE ? OR explanation LIKE ?', "%#{keyword}%", "%#{keyword}%"])
      end
      recipes
    end
  end

  # レシピ特徴検索
  def self.feature_search(search)
    requirement = search.select! { |_k, v| v.present? }
    features = Feature.where(requirement)
    id_list = features.pluck(:recipe_id)
    Recipe.where(id: id_list)
  end
end
