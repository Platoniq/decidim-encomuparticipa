require 'csv'

ORG=1
KEEP=%w( ivan@platoniq.net )

namespace :bec do
	namespace :users do
	  desc "Handles BcnEnComu common operations with users"
	  task count: :environment do
  		lines = get_lines
  		emails = filter_emails(lines)
  		registered = get_registered(emails)
  		unregistered = get_unregistered(emails)
  		pirates = get_pirates(emails)
  		puts "Found #{emails.count} emails in #{lines.count} lines"
  		puts "#{registered.count} registered users"
  		puts "#{unregistered.count} unregistered users"
  		puts "#{pirates.count} pirate users"
  		if pirates
  			puts "Use bec:users:delete_pirates to remove pirates"
  		end
	  end

	  task registered: :environment do
  		lines = get_lines
  		emails = filter_emails(lines)
  		puts get_registered(emails).pluck(:email)
	  end

	  task unregistered: :environment do
  		lines = get_lines
  		emails = filter_emails(lines)
  		puts get_unregistered(emails)
	  end

	  task pirates: :environment do
  		lines = get_lines
  		emails = filter_emails(lines)
  		puts get_pirates(emails).pluck(:email)
	  end

	  task delete_pirates: :environment do
  		lines = get_lines
  		emails = filter_emails(lines)
  		pirates = get_pirates(emails)
  		reason = "Administrative removal at #{DateTime.now}"
  		pirates.each do |u|
  			puts "Destroying user #{u.id} #{u.name} #{u.email}"
    		Decidim::DestroyAccount.call(u, OpenStruct.new(valid?: true, delete_reason: reason))
	  	end
	  end

		def	get_lines
			begin
		  	file = ARGV[1]
		  	usage if file.blank?
				CSV.read(file).pluck(0)
			rescue => e
	  		p e.message
	  		usage
			end
		end

	  def filter_emails(lines)
	  	lines.select { |l| l.include?('@') }
	  end

	  def get_registered(emails)
	  	Decidim::User.where(decidim_organization_id: ORG, email: emails)
	  end

	  def get_unregistered(emails)
	  	registered = get_registered(emails).pluck(:email)
	  	emails.reject { |e| registered.include? e }
	  end

	  def get_pirates(emails)
	  	emails = emails | KEEP
	  	Decidim::User.where(decidim_organization_id: ORG).where.not(email: emails)
	  end

	  def usage
	  	puts "\nUSAGE:\n"
	  	puts "bin/rails bec:users file.csv\n"
	  	puts "\tCount registered/unregistered users from a csv list"
	  	puts "bin/rails bec:users:registered file.csv\n"
	  	puts "\tList registered users from a csv list"
	  	puts "bin/rails bec:users:unregistered file.csv\n"
	  	puts "\tList unregistered users from a csv list"
	  	puts "bin/rails bec:users:pirates file.csv\n"
	  	puts "\tList pirates users from a csv list"
	  	puts "bin/rails bec:users:delete_pirates file.csv\n"
	  	puts "\tDestroy account for the pirates users from a csv list"

	  	exit
	  end
	end

	task users: 'bec:users:count'
end
