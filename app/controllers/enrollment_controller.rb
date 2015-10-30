class EnrollmentController < ApplicationController
  include Wicked::Wizard

  layout 'enrollment'

  steps :package_type, :personal_information, :education, :other_information, :terms_and_conditions,
        :payment, :confirmation

  before_action :set_student, only: [:show]
  before_action :set_student_2, only: [:update]
  before_action :set_season
  before_action :update_enrollment_status, only: [:show]

  def show
    @page = 'enrollment'
    if !ReviewSeason.current
      redirect_to root_path, flash: {alert: 'There is no ongoing review season as of this moment.'}
    elsif @student && @student.enrolled_once?
      redirect_to root_path, flash: {alert: 'Student is already enrolled.'}
    elsif step == :personal_information && !((@student && valid_package(@student.package_type)) || valid_package(params[:package_type]))
      redirect_to previous_wizard_path, flash: {error: 'Package type is invalid.'}
    else
      @season = ReviewSeason.current if (step == :terms_and_conditions || step == :payment) && ReviewSeason.exists?
      render_wizard
    end
  end

  def valid_package(pck)
    %w{Standard Double Coaching}.include? pck
  end

  def update
    @page = 'enrollment'
    if process_step
      flash[:alert] = nil
      if @student
        redirect_to next_wizard_path(:student_id => @student.id)
      elsif @type
        redirect_to next_wizard_path(package_type: @type)
      end
    else
      if @student
        render_wizard @student
      else
        flash[:alert] = 'Please select package type.'
        render_wizard
      end
    end
  end

  private
  def process_step
    if step == :package_type
      @type = params[:package_type]
      @type.present?
    elsif step ==:personal_information
      @student.assign_attributes student_params
      @student.save_profile_pic params[:student][:profile_pic], params[:student][:clean]
      @student.save
    elsif step == :terms_and_conditions
      @student.update_attributes({agreed: true})
      @student.setup_payment
    elsif step == :payment
      @student.finish_enrollment_process
    else
      @student.update_attributes student_params
    end
  end

  def set_season
    @season = ReviewSeason.current
  end

  def set_student
    if params[:student_id]
      @student = Student.find(params[:student_id])
    else
      @student = Student.new({enrollment_process: step_index_for(step), package_type: params[:package_type]})
    end
  end

  def set_student_2
    return if step == :package_type
    if params[:student_id]
      @student = Student.find(params[:student_id])
    else
      @student = Student.new student_params
    end
  end

  def student_params
    params.require(:student).permit(:first_name, :middle_name, :last_name, :birthdate, :sex, :civil_status, :address, :contact_no, :email,
                                    :parent_first_name, :parent_last_name, :parent_contact, :last_attended, :college_year,
                                    :recognition, :hs, :hs_year, :elem, :elem_year, :referrer_first_name, :referrer_last_name,
                                    :why, :facebook, :twitter, :linkedin, :enrollment_process, :package_type, :civil_status)
  end

  def update_enrollment_status
    @student.enrollment_process = step_index_for step
  end
end
