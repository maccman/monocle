require 'active_support/core_ext/string'
require 'active_support/core_ext/array'
require 'active_support/core_ext/hash'
require 'lib/sequel/url_validation_helpers'
require 'lib/sequel/save_helpers'

Sequel.default_timezone = :utc

Sequel.extension :core_extensions
Sequel.extension :pg_array
Sequel.extension :pg_array_ops

Sequel::Model.raise_on_save_failure = false

Sequel::Model.plugin :timestamps
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :serialization
Sequel::Model.plugin Sequel::Plugins::URLValidationHelpers
Sequel::Model.plugin Sequel::Plugins::SaveHelpers

Sequel::Plugins::Serialization.register_format(:json,
  lambda{|v| v.to_json },
  lambda{|v| JSON.parse(v, :symbolize_names => true) }
)

Sequel::Plugins::Serialization.register_format(:pg_uuid_array,
  lambda{|v| Sequel::Postgres::PGArray.new(v, :uuid) },
  lambda{|v| Sequel::Postgres::PGArray::Parser.new(v).parse }
)

Sequel::Postgres::PGArray.register('uuid', :type_symbol => :string)

module Brisk
  module Models
    autoload :Comment, 'app/models/comment'
    autoload :CommentVote, 'app/models/comment_vote'
    autoload :PostVote, 'app/models/post_vote'
    autoload :PostVisit, 'app/models/post_visit'
    autoload :Post, 'app/models/post'
    autoload :User, 'app/models/user'
    autoload :UserInvite, 'app/models/user_invite'
    autoload :Mailer, 'app/models/mailer'
    autoload :Tweeter, 'app/models/tweeter'
  end
end