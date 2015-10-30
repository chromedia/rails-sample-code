class ReviewSeason
  include Mongoid::Document

  field :season, type: String
  validates_presence_of :season
  validates_length_of :season, minimum: 3
  validates_uniqueness_of :season

  field :season_start, type: Date
  validates_presence_of :season_start

  field :season_end, type: Date
  validates_presence_of :season_end

  field :promo_start, type: Date
  field :promo_end, type: Date

  field :first_timer, type: BigDecimal
  validates_numericality_of :first_timer, greater_than_or_equal_to: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  field :repeater, type: BigDecimal
  validates_numericality_of :repeater, greater_than_or_equal_to: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  field :full_review, type: BigDecimal
  validates_presence_of :full_review
  validates_numericality_of :full_review, greater_than: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  field :double_review, type: BigDecimal
  validates_presence_of :double_review
  validates_numericality_of :double_review, greater_than: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  field :coaching, type: BigDecimal
  validates_presence_of :coaching
  validates_numericality_of :coaching, greater_than: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  field :reservation, type: BigDecimal
  validates_presence_of :reservation
  validates_numericality_of :reservation, greater_than: 0, less_than: 1000000, message: 'must be less than 999,999.00'

  validate :date_precedence

  has_many :enrollments, class_name: 'StudentEnrollment', dependent: :restrict
  has_many :grades, dependent: :destroy
  has_many :tests, dependent: :destroy

  def date_precedence
    if season_start.present? && season_end.present? && season_start + 1.day > season_end
      errors[:season_end] << 'must be after the start of the season'
    end

    if promo_start.blank? && promo_end.present?
      errors[:promo_start] << 'must be defined'
    end

    if promo_start.present? && promo_end.blank?
      errors[:promo_end] << 'must be defined'
    end

    if promo_start.present? && promo_end.present? && promo_start > promo_end
      errors[:promo_end] << 'must be after the start of the promo'
    end
  end

  def self.previous
    if ReviewSeason.count > 0
      prev = ReviewSeason.all.select { |r| r.season_end < Date.today }
      prev.sort_by { |r| r.season_end }.last unless prev.empty?
    end
  end

  def self.current
    if ReviewSeason.exists?
      last = ReviewSeason.all.select do |r|
        r.season_start <= Date.today && r.season_end >= Date.today
      end
      last.first
    end
  end

  def get_fee(package)
    if package == 'Coaching'
      coaching
    else
      full_review
    end
  end

  def to_s
    season
  end

  def students
    enrollments.map { |e| e.student }
  end

  def enrolled_students
    enrolled.map { |e| e.student }
  end

  def enrolling
    enrollments.where(status_cd: 1)
  end

  def enrolled
    enrollments.where(status_cd: 2)
  end

  def self.descending
    ReviewSeason.desc(:season_start)
  end

  def promo_still_active?
    if promo_start && promo_end
      promo_start <= Date.today && Date.today <= promo_end
    end
  end
end
