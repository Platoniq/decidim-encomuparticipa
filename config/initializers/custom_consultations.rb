# frozen_string_literal: true

# Custom consultation rules

Rails.application.config.to_prepare do
  # Admin validation customization
  # Decidim::Consultations::Admin::QuestionConfigurationForm.class_eval do
  #   def min_lower_than_max
  #     errors.add(:max_votes, 'Let\'s fail always!')
  #   end
  # end
  #
  # Vote validation override
  # Decidim::Consultations::MultipleVoteQuestion.class_eval do
	 #  def check_num_votes
	 #  	raise StandardError, 'You cannot vote ha ha ha!!! 🃏'
	 #  end
  # end
end