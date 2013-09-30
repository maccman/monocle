namespace :brisk do
  task :scheduled => :app do
    posts = Brisk::Models::Post.scheduled_due.all
    posts.each(&:publish!)
  end
end