## Monocle

Monocle is a link and news aggregation website.

http://monocle.io

### Prerequisites

* Ruby 2.0
* Postgres
* Redis
* A GitHub app account
* A Twitter app account

### Setup

    bundle install
    createdb monocle_development
    rake db:migrate

    export GITHUB_KEY=123
    export GITHUB_SECRET=123

    export TWITTER_KEY=123
    export TWITTER_SECRET=123

    thin start