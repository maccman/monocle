# Setup

  bundle install
  createdb monocle_development
  rake db:migrate

  export GITHUB_KEY=123
  export GITHUB_SECRET=123

  export TWITTER_KEY=123
  export TWITTER_SECRET=123

  thin start