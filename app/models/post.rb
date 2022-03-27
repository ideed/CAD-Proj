class Post < ApplicationRecord
  acts_as_votable
  validates :title, :body, presence: true
  has_many :comments
  after_save :touch_comments

  def touch_comments
    comments.each(&:touch)
  end
end
