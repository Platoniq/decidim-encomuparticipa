# frozen_string_literal: true

# We are using the same DirectVerifications engine without the admin part to
# create a 10 different custom verifications

Decidim::Verifications.register_workflow(:direct_verifications_vella) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_eixample) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_sants) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_corts) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_sarria) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_gracia) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_horta) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_barris) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_andreu) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end
Decidim::Verifications.register_workflow(:direct_verifications_marti) do |workflow|
  workflow.engine = Decidim::DirectVerifications::Verification::Engine
end

# We need to tell the plugin to handle this method in addition to the default "Direct verification". Any registered workflow is valid.
Decidim::DirectVerifications.configure do |config|
  config.manage_workflows = %w(direct_verifications_vella direct_verifications_eixample direct_verifications_sants direct_verifications_corts direct_verifications_sarria direct_verifications_gracia direct_verifications_horta direct_verifications_barris direct_verifications_andreu direct_verifications_marti)
end