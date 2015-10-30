module EnrollmentHelper
  def first_step?
    step == wizard_steps.first
  end

  def last_step?
    step == wizard_steps.last
  end

  def active_indicator?(_step)
    _step == step || past_step?(_step)
  end

  def paypal_class
    'hidden' unless step.eql? :payment
  end

  def next_button
    if last_step?
      'Done'
    elsif step.eql? :terms_and_conditions
      'I Agree'
    elsif step.eql? :payment
      'Skip'
    else
      'Next'
    end
  end

  def prev_wizard_link
    if first_step?
      root_path
    else
      if @student && !@student.new_record?
          previous_wizard_path(student_id: @student.id)
      else
        previous_wizard_path
      end
    end
  end
end
