# Entry point for Decidim. It will use the `DecidimController` as
# entry point, but you can change what controller it inherits from
# so you can customize some methods.
class DecidimController < ApplicationController
	http_basic_authenticate_with name: ENV['STAGING_USER'],
								 password: ENV['STAGING_PASSWORD'],
								 if: -> { request.subdomain == ENV['STAGING_SUBDOMAIN'] unless ENV['STAGING_SUBDOMAIN'].blank? }
end
