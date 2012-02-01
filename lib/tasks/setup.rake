namespace :challah do
  desc "Setup the challah gem within this rails app."
  task :setup => [ "challah:setup:migrations", "db:migrate", "challah:setup:seeds", "challah:banner" ]
  
  task :banner do
    banner = <<-str

  ==========================================================================
  Challah has been set up successfully!

  Your app now as a few new models:

    - User
    - Role
    - Permission

  And some new routes set up for /sign-in and /sign-out. You can use these 
  for the built-in sign in page or roll your own if you'd prefer.

  A default user with administrator permissions has been created with the 
  following credentials:

    Username: admin
    Password: abc123

  ==========================================================================
  
    str
    
    puts banner
  end
  
  namespace :setup do
    desc "Copy migrations from challah gem"
    task :migrations do
      puts "Copying migrations..."    
      ENV['FROM'] = 'challah_engine'
      Rake::Task['railties:install:migrations'].invoke
    end
    
    desc "Load seed data"
    task :seeds => :environment do
      puts "Populating seed data..." 
      Challah::Engine.load_seed
    end
  end
end