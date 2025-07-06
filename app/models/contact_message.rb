class ContactMessage < ApplicationRecord
  belongs_to :user
  has_many :contact_responses, dependent: :destroy

  validates :subject, presence: true, length: { maximum: 255 }
  validates :message, presence: true, length: { maximum: 2000 }
  validates :status, presence: true, inclusion: { in: %w[new in_progress resolved closed] }
  validates :priority, inclusion: { in: %w[low normal high urgent] }

  scope :unresolved, -> { where(status: ['new', 'in_progress']) }
  scope :resolved, -> { where(status: ['resolved', 'closed']) }
  scope :by_priority, -> { order(Arel.sql("CASE priority WHEN 'urgent' THEN 1 WHEN 'high' THEN 2 WHEN 'normal' THEN 3 WHEN 'low' THEN 4 END")) }
  scope :recent, -> { order(created_at: :desc) }

  before_validation :set_defaults, on: :create

  def resolved?
    status.in?(['resolved', 'closed'])
  end

  def urgent?
    priority == 'urgent'
  end

  def high_priority?
    priority.in?(['urgent', 'high'])
  end

  def status_color
    case status
    when 'new' then 'red'
    when 'in_progress' then 'yellow'
    when 'resolved' then 'green'
    when 'closed' then 'gray'
    else 'gray'
    end
  end

  def priority_color
    case priority
    when 'urgent' then 'red'
    when 'high' then 'orange'
    when 'normal' then 'blue'
    when 'low' then 'gray'
    else 'gray'
    end
  end

  def latest_response
    contact_responses.order(created_at: :desc).first
  end

  def response_count
    contact_responses.count
  end

  private

  def set_defaults
    self.status ||= 'new'
    self.priority ||= 'normal'
  end
end
