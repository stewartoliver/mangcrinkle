class OrderNote < ApplicationRecord
  belongs_to :order

  validates :content, presence: true, length: { minimum: 1, maximum: 1000 }
  validates :admin_user, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def formatted_content
    content.gsub(/\n/, '<br>').html_safe
  end
end 