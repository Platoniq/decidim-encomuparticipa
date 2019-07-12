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
  Decidim::Consultations::Response.class_eval do
    def is_suplent(lang)
      title[lang]&.match(/([\- ]+)(suplent)([\- ]+)/i)
    end
  end

  Decidim::Consultations::Question.class_eval do
    def get_suplents(lang)
      responses.select do |r|
        r.is_suplent(lang)
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
  Decidim::Consultations::MultipleVoteQuestion.class_eval do
	  def check_num_votes
      question = forms&.first&.context&.current_question
        if question
          return if (suplents_ok?(forms) && candidats_ok?(forms)) || group_ok?(forms)
        end
      raise StandardError, I18n.t("activerecord.errors.models.decidim/consultations/vote.attributes.question.invalid_num_votes")
	  end

    def group_ok?(forms)
      question = forms&.first&.context&.current_question
      groups = forms.map {|f| f.response.response_group.id }.uniq
      return false if groups.count > 1
      valid = question.responses.select {|r| r.response_group.id == groups[0]}.map {|r| r.id }
      valid.count == forms.count
    end

    def suplents_ok?(forms)
      get_suplents(forms).count == Decidim.config.suplents_number
    end

    def candidats_ok?(forms)
      question = forms&.first&.context&.current_question
      get_candidats(forms).count == question.max_votes - Decidim.config.suplents_number
    end

    def get_suplents(forms)
      forms.select do |f|
        f.response.is_suplent(I18n.locale.to_s)
      end
    end

    def get_candidats(forms)
      forms.reject do |f|
        f.response.is_suplent(I18n.locale.to_s)
      end
    end
  end

end