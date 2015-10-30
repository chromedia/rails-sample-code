class StudentEnrollment
  include Mongoid::Document
  include SimpleEnum::Mongoid

  as_enum :status, enrolling: 1, enrolled: 2
  validates_presence_of :status

  belongs_to :student
  belongs_to :review_season

  has_many :answer_sheets, dependent: :destroy
  has_many :student_grades, dependent: :destroy
  has_many :invoices, class_name: 'StudentInvoice', dependent: :destroy

  scope :enrolled, -> do
    StudentEnrollment.where(status_cd: 2)
  end

  before_validation do |e|
    e.status = :enrolling unless e.persisted?
  end

  def enrolled?
    status == :enrolled
  end

  def enrolling?
    status == :enrolling
  end

  def enroll
    self.status = :enrolled
    student.is_enrolling = false
    student.save
    save
  end

  def create_invoice(hash)
    i = StudentInvoice.new(hash)
    i.student_enrollment = self
    i.save
    i
  end

  def check_paid_transactions
    sum_total = invoices.map { |i| i.sum }.sum
    enroll if sum_total >= review_season.reservation
  end
end
