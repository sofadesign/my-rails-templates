# rain_dogs.rb
# from Fabrice Luraine
#
# inspired by:
#   => http://github.com/tomafro/dotfiles/master/resources/rails/bundler.rb
#   => http://github.com/jeremymcanally/rails-templates
#   => http://asciicasts.com/episodes/148-app-templates-in-rails-2-3
#   => http://www.railsboost.com/
#
# Usage:
#   rails testapp -m http://github.com/sofadesign/my-rails-templates/raw/master/rain_dogs.rb
#


# Init git repository
  git :init

# Set up .gitignore files
  run "touch tmp/.gitignore log/.gitignore vendor/.gitignore"
  run %{find . -type d -empty | grep -v "vendor" | grep -v ".git" | grep -v "tmp" | xargs -I xxx touch xxx/.gitignore}
  file '.gitignore', <<-END
.DS_Store
log/*.log
tmp/**/*
config/database.yml
db/*.sqlite3
.bundle
END

# Copy database.yml for distribution use
  run "cp config/database.yml config/database.yml.example"

# Delete unnecessary files
  run "rm README"
  run "rm public/index.html"
  run "rm public/favicon.ico"
  run "rm public/robots.txt"
  run "rm -f public/javascripts/*"

# Download latest JQuery
  run "curl -L http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js > public/javascripts/jquery.js"
  run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"

# Setting bundler
append_file '/config/preinitializer.rb', %{
begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  if Bundler::VERSION <= "0.9.5"
    raise RuntimeError, "Bundler incompatible.\n" +
      "Your bundler version is incompatible with Rails 2.3 and an unlocked bundle.\n" +
      "Run `gem install bundler` to upgrade or `bundle lock` to lock."
  else
    Bundler.setup
  end
end
}.strip

gsub_file 'config/boot.rb', "Rails.boot!", %{

class Rails::Boot
 def run
   load_initializer
   extend_environment
   Rails::Initializer.run(:set_load_path)
 end

 def extend_environment
   Rails::Initializer.class_eval do
     old_load = instance_method(:load_environment)
     define_method(:load_environment) do
       Bundler.require :default, Rails.env
       old_load.bind(self).call
     end
   end
 end
end

Rails.boot!
}

file 'Gemfile', %{
source 'http://rubygems.org'

gem 'rails', '#{Rails::VERSION::STRING}'
gem 'rack', :version => '~> 1.1.0'
gem "sqlite3-ruby", :require => "sqlite3"
gem 'haml', :version => '~> 3.0.13'
gem 'maruku'
gem "configatron", :version => '~> 2.0'
gem 'will_paginate', :version => '~> 2.3.14'
gem 'factory_girl', :version => '~> 1.3.1'
gem 'warden'
gem 'devise', :version => "~> 1.0.8", :require => "warden"
gem 'asset_packager'
gem 'paperclip', :version => "~> 2.3.3"
gem 'jrails', :version => "~> 0.6.0"
gem 'acts_as_list', :version => "1.0.8"
gem 'exception_notification'

group :development do
  gem 'ruby-debug'
  gem 'rails-footnotes'
end

group :test do
  # bundler requires these gems while running tests
  gem 'rspec-rails', :require => 'rspec'
  gem 'faker'
  gem 'mocha'
  gem 'shoulda'
end
}.strip

run 'bundle install'

# Setup Devise
  generate :devise_install

# Generate
  generate :rspec
  
# Set local to EN and Generate Locale Files 
  generate 'i18n_locale en'
  
# Git first add and commit
  git :add => '.'
  git :commit => "-m 'Initial commit (app generated with rain_dogs.rb template).'"

