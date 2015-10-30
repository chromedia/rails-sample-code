class Student < Person
  include Util

  DAYS_TILL_EXPIRATION = 3

  validates_presence_of :civil_status, if: :can_validate_info?
  validates_presence_of :sex, if: :can_validate_info?
  validates_presence_of :address, if: :can_validate_info?
  validates_presence_of :contact_no, if: :can_validate_info?
  validates_presence_of :email, if: :can_validate_info?

  field :parent_first_name, type: String
  field :parent_last_name, type: String
  field :parent_contact, type: String

  field :last_attended, type: String
  validates_presence_of :last_attended, if: :can_validate_education?

  field :college_year, type: Integer
  validates_presence_of :college_year, if: :can_validate_education?
  validates_numericality_of :college_year, greater_than: :hs_year, message: 'must be later than High School Year', if: :can_validate_education?

  field :recognition, type: String
  field :hs, type: String
  validates_presence_of :hs, if: :can_validate_education?

  field :hs_year, type: Integer
  validates_presence_of :hs_year, if: :can_validate_education?
  validates_numericality_of :hs_year, greater_than: :elem_year, message: 'must be later than Elementary Year', if: :can_validate_education?

  field :elem, type: String
  validates_presence_of :elem, if: :can_validate_education?

  field :elem_year, type: Integer
  validates :elem_year, presence: true, if: :can_validate_education?

  field :referrer_first_name, type: String
  field :referrer_last_name, type: String
  field :referrer_contact, type: String

  field :why, type: String
  field :facebook, type: String
  field :twitter, type: String
  field :linkedin, type: String
  field :enrollment_process, type: Integer, default: 0
  field :agreed, type: Boolean
  field :finish_enrollment_on, type: DateTime
  field :package_type, type: String
  field :profile_pic, type: String

  # Caching purposes
  field :is_enrolling, type: Boolean, default: false
  field :search_terms, type: String

  has_many :enrollments, class_name: 'StudentEnrollment', dependent: :destroy

  scope :filter, ->(season, status) do
    if season.nil? || season == '0' # No season filter
      if status.nil? || status == '-1'
        Student.all
      else
        ids = StudentEnrollment.where(status_cd: status.to_i).map { |e| e.student.id }
        Student.in(id: ids)
      end
    else # With season filter
      s = ReviewSeason.find(season)
      if s && status.nil? || status == '-1'
        Student.in(id: s.enrollments.map { |e| e.student.id })
      elsif s
        ids = s.enrollments.select { |e| e.status_cd == status.to_i }.map { |e| e.student.id }
        Student.in(id: ids)
      else
        Student.all
      end
    end
  end

  before_validation do |d|
    d.search_terms = "#{first_name} #{last_name} #{middle_name} #{email} #{last_attended} #{address}"
  end

  #for enrollment only
  def setup_payment
    current_season = ReviewSeason.current
    return true if has_enrollment_on(current_season) && current_invoices.any?
    e = enrollment_on(current_season)
    invoice1 = e.create_invoice(
        package: package_type,
        amount: current_season.get_fee(package_type)
    )

    if current_season.promo_still_active? && package_type == 'Standard'
      invoice1.amount = current_season.first_timer
      invoice1.description = 'First Timer'
      invoice1.save
    end

    if package_type == 'Double'
      invoice1.description = 'Invoice 1 of 2'
      invoice1.save
      amount = current_season.double_review - current_season.full_review
      e.create_invoice(
          package: package_type,
          description: 'Invoice 2 of 2',
          amount: amount
      )
    end
    expire
    save
  end

  def invoices
    enrollments.map { |e| e.invoices }.flatten
  end

  def balance
    invoices.map { |i| i.balance }.sum
  end

  def has_balance?
    balance > 0
  end

  def enrolling?
    if current_enrollment
      current_enrollment.enrolling?
    else
      false
    end
  end

  def has_enrollment_on(season)
    enrollments.any? { |x| x.review_season == season }
  end

  def enrollment_on(season)
    StudentEnrollment.find_or_create_by(review_season: season.id, student: self.id)
  end

  def enrollment_status
    if current_enrollment
      current_enrollment.status
    else
      :undefined
    end
  end

  def current_enrollment
    enrollments.sort_by { |i| i.review_season.season_start }.last
  end

  def enrolled?
    if current_enrollment
      current_enrollment.enrolled?
    else
      false
    end
  end

  def enrolled_once?
    enrollments.enrolled.exists?
  end

  def current_season
    current_enrollment.review_season if current_enrollment
  end

  def current_invoice
    current_invoices.first unless current_invoices.empty?
  end

  def current_invoices
    if current_enrollment
      current_enrollment.invoices
    else
      []
    end
  end

  def total_current_amount
    current_invoices.reduce(0) { |sum, i| sum+i.amount }
  end

  def finish_enrollment_process
    self.finish_enrollment_on = DateTime.now
    self.save
  end

  def expired?
    (finish_enrollment_on && DateTime.now > finish_enrollment_on + DAYS_TILL_EXPIRATION.days) || (!finish_enrollment_on && enrollment_status.present?)
  end

  def as_json(opt = nil)
    hash = self.serializable_hash(nil)
    hash[:middle_initial] = middle_initial
    hash[:id] = id.to_s
    hash[:enrollment_status] = enrollment_status
    hash[:current_season] = current_season.season if current_season
    hash[:user_id] = user.id.to_s if user.present?
    hash[:user_id] = nil if user.nil?
    hash[:balance] = balance unless balance.nil?
    hash.as_json(nil)
  end

  def has_profile_pic?
    profile_pic.present?
  end

  def save_profile_pic(img, clean)
    unless clean == 'true'
      self.profile_pic = save_file(img, id.to_s, profile_pic, 'students')
    end
  end

  def expire
    destroy unless enrolled?
  end

  private
  def can_validate_info?
    enrollment_process == 0 || enrollment_process == 1
  end

  def can_validate_education?
    enrollment_process == 0 ||enrollment_process == 2
  end

  def can_validate_others?
    enrollment_process == 0 || enrollment_process == 3
  end

  handle_asynchronously :expire, run_at: Proc.new { 3.days.from_now }
end
