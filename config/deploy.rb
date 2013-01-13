load 'deploy/assets'

set :application, "cricket"
set :repository,  "git@github.com:lordp/cricket.git"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, 'darrylh'
set :domain, 'cricket.addict.net.nz'
set :use_sudo, false

set :deploy_to, "/var/www/#{application}"
set :deploy_via, :remote_cache

set :rails_env, 'production'

role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_shared do
    run "ln -sfn #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  task :bundle_install, :roles => :app do
    run "cd #{release_path} && bundle install"
  end
end

after "deploy:update_code", 'deploy:bundle_install', 'deploy:symlink_shared'
