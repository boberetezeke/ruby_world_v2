namespace :git_base do
  desc "Reset git database"
  task :reset => :environment do
    [Todo, Contact].each{|klass| klass.create_git_for_all}
  end
end
