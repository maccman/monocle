task :release do
  `git push production master`
end

namespace :release do
  task :migrate do
    `heroku run rake db:migrate`
  end
end

namespace :staging do
  task :release do
    branch = `git symbolic-ref --short HEAD`.chomp
    `git push -f staging #{branch}:master`
  end

  namespace :release do
    task :migrate do
      `heroku run 'rake db:migrate' --app monocle-staging`
    end
  end
end

namespace :edge do
  task :release do
    branch = `git symbolic-ref --short HEAD`.chomp
    `git push -f edge #{branch}:master`
  end
end