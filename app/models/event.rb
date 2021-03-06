class Event < ActiveRecord::Base
  belongs_to :venue
  belongs_to :category
  belongs_to :user
  has_many :ticket_types, dependent: :destroy

  accepts_nested_attributes_for :venue, :ticket_types

  validates_presence_of :extended_html_description, :venue, :category, :starts_at
  validates_uniqueness_of :name, uniqueness: {scope: [:venue, :starts_at]}

  def lowest_price_or_default
    ticket_types.any? ? ticket_types.order(:price).first.price : 0
  end

  def total_quantity
    ticket_types.sum { |t| t.max_quantity }
  end

  def have_enough_ticket_types?
    ticket_types.count >= 1
  end

  def outdated_event?
    starts_at < Time.now
  end

  # def self.published?
  #  where(published_at: nil)
  # end
  scope :published, -> { where.not(published_at: nil) }

  def self.upcoming
    where("starts_at > ?", Time.now)
  end

  def self.search(search)
    where("name ILIKE ?", "%#{search}%")
  end

  delegate :name, to: :venue, allow_nil: true, prefix: true
  # def venue_name
  #   if venue
  #     venue.name
  #   else
  #     nil
  #   end
  # end
end
