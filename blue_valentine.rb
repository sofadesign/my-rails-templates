# blue_valentine.rb
# from Fabrice Luraine
#
# inspired by:
#   => http://github.com/jeremymcanally/rails-templates
#   => http://asciicasts.com/episodes/148-app-templates-in-rails-2-3
#   => http://www.railsboost.com/

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
  run "curl -L http://ajax.googleapis.com/ajax/libs/jquery/1.3/jquery.min.js > public/javascripts/jquery.js"
  run "curl -L http://jqueryjs.googlecode.com/svn/trunk/plugins/form/jquery.form.js > public/javascripts/jquery.form.js"
  
# Install plugins as git submodules
plugin 'asset_packager', :submodule => true,
  :git => 'http://synthesis.sbecker.net/pages/asset_packager'
plugin 'paperclip', :submodule => true,
  :git => "git://github.com/thoughtbot/paperclip.git"
plugin 'jrails', :submodule => true,
  :git => "git://github.com/aaronchi/jrails.git"
plugin 'acts_as_list', :submodule => true,
  :git => "git://github.com/rails/acts_as_list.git"
plugin 'inherited_resources', :submodule => true,
  :git => "git://github.com/josevalim/inherited_resources.git"
plugin 'formtastic', :submodule => true,
  :git => "git://github.com/justinfrench/formtastic.git"
plugin 'rails-footnotes', :submodule => true,
  :git => "git://github.com/josevalim/rails-footnotes.git"
plugin 'rspec', :submodule => true, 
  :git => 'git://github.com/dchelimsky/rspec.git'
plugin 'rspec-rails', :submodule => true, 
  :git => 'git://github.com/dchelimsky/rspec-rails.git'
plugin 'exception_notifier', :submodule => true, 
  :git => 'git://github.com/rails/exception_notification.git'
 
# Initialize submodules
  git :submodule => "init"
  
# Install gems
  gem 'haml', :version => "~> 2.0"
  gem 'maruku'
  gem "configatron", :version => "~> 2.0"
  gem 'mislav-will_paginate', :version => '~> 2.2.3', :lib => 'will_paginate', :source => 'http://gems.github.com'
  gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com'
  gem 'warden'
  gem 'devise'
  rake 'gems:install', :sudo => true
  
# Setup Devise
  rake 'devise:setup'

# Generate
  generate :rspec  
  
# Git first add and commit
  git :add => '.'
  git :commit => "-m 'Initial commit (app generated with blue_valentine.rb template).'"

