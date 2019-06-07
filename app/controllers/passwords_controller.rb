class PasswordsController < Decidim::Devise::PasswordsController
  protected
  def after_resetting_password_path_for(resource)
 	c = Decidim::Consultation&.active&.first
  	return "/consultations/#{c.slug}" if c
	Devise.sign_in_after_reset_password ? after_sign_in_path_for(resource) : new_session_path(resource_name)
  end
end