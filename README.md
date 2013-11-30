## Monocle

Monocle is a link and news aggregation website.

http://monocle.io

![Screenshot](http://maccman.github.io/monocle/screenshot.png)

### Prerequisites

* Ruby 2.0
* Postgres 9.3
* Redis
* A GitHub app account
* A Twitter app account

### Setup

    bundle install
    createdb monocle_development
    rake db:migrate

### Configuration
Monocle needs a few configuration variables to work properly.
You can export them from your terminal like in the following example:

    export GITHUB_KEY=123
    export GITHUB_SECRET=123

    export TWITTER_KEY=123
    export TWITTER_SECRET=123

Or you can copy the included .sample.env into a .env file and set all your
variables there.

### First time user
To become administrator as first time user, first start Monocle with:

    thin start

Login with twitter or github into Monocle, then open a terminal and open Monocle inside an IRB session with:

    irb -r ./app.rb

From there execute:

    user = Brisk::Models::User.first
    user.admin = true
    user.registered = true
    user.save

Now you will be able to post, comment and invite users.
