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
      title[lang]&.match(/([\- ]+)(suplente?)([\- ]+)/i)
    end
    def is_blanc(lang)
      title[lang]&.match(/([\- ]+)(blanco?)([\- ]+)/i)
    end
  end

  Decidim::Consultations::Question.class_eval do
    # Ensure order by time
    def sorted_responses
      responses.order({decidim_consultations_response_group_id: :asc, created_at: :asc})
    end

    def get_suplents(lang)
      responses.select do |r|
        r.is_suplent(lang)
      end
    end
  end

  Decidim::Consultations::Admin::ResponsesController.class_eval do
    def index
      enforce_permission_to :read, :response
      return unless current_question.multiple?
      errors = []
      current_question.title.each do |l,t|
        errors << l if current_question.get_suplents(l).count < current_question.min_votes.to_i
      end
      flash.now[:alert] = "El numero de suplents en els idiomes [#{errors.join(', ')}] es inferior a #{current_question.min_votes}" unless errors.blank?
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
    def locale
      # I18n.locale.to_s
      'ca'
    end

	  def check_num_votes
      Rails.logger.debug "===VOTE==="
       @question = forms&.first&.context&.current_question
        if @question
          return if num_votes_ok?(forms) || group_ok?(forms) || is_blanc?(forms)
        end
      Rails.logger.debug "===ERROR==="
      raise StandardError, I18n.t("activerecord.errors.models.decidim/consultations/vote.attributes.question.invalid_num_votes")
	  end

    def is_blanc?(forms)
      Rails.logger.debug "===is_blanc? Total blancs #{get_blancs(forms).count} total forms #{@forms.count}"
      (get_blancs(forms).count == forms.count) && (forms.count > 0)
    end

    def group_ok?(forms)
      groups = forms.map {|f| f.response.response_group&.id }.uniq
      Rails.logger.debug "===group_ok? groups found #{groups.count}, group ids #{groups}"
      return false if groups.count > 1 || groups.count == 0 || groups[0].blank?
      # max votable titular/suplents in this group
      valid = @question.responses.select {|r| r.response_group&.id == groups[0]}
      valid_suplents = valid.select {|r| r.is_suplent locale }.count
      min_titulars = [valid.count - valid_suplents, @question.max_votes - @question.min_votes].min
      min_suplents = [valid_suplents, @question.min_votes].min
      total_titulars = get_candidats(forms).count
      total_suplents = get_suplents(forms).count

      Rails.logger.debug "===group_ok? Total titulars in group #{groups[0]}: #{total_titulars} expected #{min_titulars}"
      Rails.logger.debug "===group_ok? Total suplents in group #{groups[0]}: #{total_suplents} expected #{min_suplents}"
      total_titulars == min_titulars && total_suplents == min_suplents
    end

    def num_votes_ok?(forms)
      Rails.logger.debug "===candidats_ok? Total candidats #{get_candidats(forms).count} expected #{@question.max_votes-@question.min_votes}"
      Rails.logger.debug "===suplents_ok? Total suplents #{get_suplents(forms).count} expected #{@question.min_votes}"
      suplents_ok?(forms) && candidats_ok?(forms)
    end

    def suplents_ok?(forms)
      get_suplents(forms).count == @question.min_votes
    end

    def candidats_ok?(forms)
      get_candidats(forms).count == @question.max_votes - @question.min_votes
    end

    def get_blancs(forms)
      forms.select do |f|
        f.response.is_blanc locale
      end
    end

    def get_suplents(forms)
      forms.select do |f|
        f.response.is_suplent locale
      end
    end

    def get_candidats(forms)
      forms.reject do |f|
        f.response.is_suplent locale
      end
    end
  end

end