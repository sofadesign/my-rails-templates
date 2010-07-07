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
.rvmrc
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
  require "rubygems"
  require "bundler"
rescue LoadError
  raise "Could not load the bundler gem. Install it with `gem install bundler`."
end

if Gem::Version.new(Bundler::VERSION) <= Gem::Version.new("0.9.24")
  raise RuntimeError, "Your bundler version is too old." +
   "Run `gem install bundler` to upgrade."
end

begin
  # Set up load paths for all bundled gems
  ENV["BUNDLE_GEMFILE"] = File.expand_path("../../Gemfile", __FILE__)
  Bundler.setup
rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems." +
    "Did you run `bundle install`?"
end
}.strip

gsub_file 'config/boot.rb', "Rails.boot!", %{

class Rails::Boot
  def run
    load_initializer

    Rails::Initializer.class_eval do
      def load_gems
        @bundler_loaded ||= Bundler.require :default, Rails.env
      end
    end

    Rails::Initializer.run(:set_load_path)
  end
end

Rails.boot!
}


# If you use RVM with ruby 1.9.x, you might need to install ruby-debug19 
# (which depend on linecache19) manually before.
# http://isitruby19.com/linecache
# gem install ruby-debug19 -- --with-ruby-include=/home/user/.rvm/src/ruby-1.9.1-p378mate

file 'Gemfile', %{
source 'http://rubygems.org'

gem 'rails', '#{Rails::VERSION::STRING}'
gem 'rack', '~> 1.1.0'
gem 'sqlite3-ruby', :require => "sqlite3"
gem 'haml', '~> 3.0.13'
gem 'maruku'
gem "configatron", '~> 2.0'
gem 'will_paginate', '~> 2.3.14'
gem 'factory_girl', '~> 1.3.1'
gem 'warden'
gem 'devise', "~> 1.0.8", :require => "warden"
gem 'asset_packager'
gem 'paperclip', "~> 2.3.3"
gem 'jrails', "~> 0.6.0"
gem 'acts_as_list', "0.1.2"
gem 'exception_notification'

group :development do
  gem "ruby-debug#{'19' if ENV['RUBY_VERSION'] =~ /ruby-1\.9\..+/}"
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

