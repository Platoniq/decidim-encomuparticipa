# frozen_string_literal: true

# Custom consultation rules

Rails.application.config.to_prepare do

  #hide buttons if no next
  Decidim::Consultations::QuestionsHelper.class_eval do
    def display_next_previous_button(direction, optional_classes = "")
      css = "card__button button hollow " + optional_classes

      case direction
      when :previous
        return '' if previous_question.nil?
        i18n_text = t("previous_button", scope: "decidim.questions")
        question = previous_question || current_question
        css << " disabled" if previous_question.nil?
      when :next
        return '' if next_question.nil?
        i18n_text = t("next_button", scope: "decidim.questions")
        question = next_question || current_question
        css << " disabled" if next_question.nil?
      end

      link_to(i18n_text, decidim_consultations.question_path(question), class: css)
    end
  end

  # Admin check suplent number
  Decidim::Consultations::Question.class_eval do
    # Ensure order by time
    def sorted_responses
      responses.order({decidim_consultations_response_group_id: :asc, created_at: :asc})
    end
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