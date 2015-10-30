module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end

  def admin_page?
    controller.is_a? AdminController
  end

  def people_page?
    (current_page? :reviewers) || (current_page? :founders) || (current_page? :our_students)
  end

  def login_page?
    (current_page? :new_user_session)
  end

  def to_currency(money)
    number_to_currency money, unit: ''
  end
end
