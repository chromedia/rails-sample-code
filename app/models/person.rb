class Person
  include Mongoid::Document
  include SimpleEnum::Mongoid

  field :first_name, type: String
  validates_presence_of :first_name

  field :middle_name, type: String
  field :last_name, type: String
  validates_presence_of :last_name

  field :birthdate, type: Date, default: Date.today
  as_enum :civil_status, %w{single married widowed separated}
  validates_presence_of :civil_status

  field :sex, type: String
  field :civil_status, type: String
  field :address, type: String
  field :contact_no, type: String
  field :email, type: String
  validates_uniqueness_of :email
  validates_format_of :email, with: Devise::email_regexp, message: 'is not in valid format'

  has_one :user

  before_validation do |d|
    d.email = d.email.downcase if d.email
  end

  def middle_initial
    if middle_name.nil?
      ''
    else
      middle_name.first.capitalize + '.'
    end
  end

  def to_s
    str = "#{last_name}, #{first_name}"
    str << ' ' << middle_name if middle_name.present?
    str
  end

  def trailing_name
    str = ", #{first_name}"
    str << ' ' << middle_name if middle_name.present?
    str
  end
end
