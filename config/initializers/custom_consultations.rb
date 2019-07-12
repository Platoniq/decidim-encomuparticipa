# frozen_string_literal: true

# Custom consultation rules

Rails.application.config.to_prepare do
  # Admin check suplent number
  Decidim::Consultations::Question.class_eval do
    def get_suplents(lang)
      responses.select do |r|
        r.title[lang].match(/([\- ]+)(suplent)([\- ]+)/i)
      end
    end
  end

  Decidim::Consultations::Admin::ResponsesController.class_eval do
    def index
      enforce_permission_to :read, :response
      errors = []
      current_question.title.each do |l,t|
        errors << l if current_question.get_suplents(l).count < Decidim.config.suplents_number
      end
      flash.now[:alert] = "El numero de suplents en els idiomes [#{errors.join(', ')}] es inferior a #{Decidim.config.suplents_number}" unless errors.blank?
    end
  end
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