require 'gravatar'
require 'bcrypt'

module Brisk
  module Models
    class User < Sequel::Model
      dataset_module do
        def ordered
          order(:created_at.desc)
        end

        def matching(attrs = {})
          where(
            {~:email => nil, :email => attrs[:email]} |
            {~:twitter => nil, :twitter => attrs[:twitter]} |
            {~:github => nil, :github => attrs[:github]}
          )
        end
      end

      one_to_many :posts, :on_delete => :cascade
      one_to_many :comments, :on_delete => :cascade

      many_to_one :parent, :class => self
      one_to_many :children, :class => self, :key => :parent_id
      one_to_many :invites, :class => 'Brisk::Models::UserInvite'

      many_to_many :voted_posts,
                   :join_table => :post_votes,
                   :class      => 'Brisk::Models::Post',
                   :left_key   => :user_id,
                   :right_key  => :post_id,
                   :on_delete => :cascade

      serialize_attributes :json, :auth

      set_allowed_columns :name, :handle, :email,
                          :about, :url, :twitter,
                          :registered, :manifesto

      def self.find_by_uid(uid)
        first(uid: uid)
      end

      def self.from_auth!(auth)
        auth           = auth.with_indifferent_access
        user           = find_by_uid(auth[:uid]) || self.new
        user.uid       = auth[:uid]
        user.provider  = auth[:provider]
        user.auth      = auth.except(:extra)
        user.name    ||= auth[:info][:name]
        user.email   ||= auth[:info][:email]
        user.handle  ||= auth[:info][:nickname]
        user.about   ||= auth[:info][:description]
        user.save
        user
      end

      def url
        super || begin
          case provider
          when 'twitter'
            urls[:Website]
          when 'github'
            urls[:Blog]
          end
        end
      end

      def urls
        auth[:urls] || {}
      end

      def avatar_url
        auth_info[:image] || Gravatar.url(email || id)
      end

      def admin?
        !!admin
      end

      def parent_name
        parent && parent.name
      end

      def increment_invites!(count = 1)
        self.this.update(:invites_count => :invites_count + count)
      end

      def decrement_invites!(count = 1)
        self.this.update(:invites_count => :invites_count - count)
      end

      def activate!(invite = nil)
        invite.use!(self) if invite
      end

      def notify_activate!
        if email.present?
          Mailer.user_activate!(self)
        end
      end

      def after_create
        check_invite!
      end

      def karma!
        self.this.update(:karma => :karma + 1)
        reload
      end

      def validate
        set_handles
        set_secret
        set_invites_count
      end

      def as_json(options = nil)
        result = {}
        user   = (options || {})[:user]

        if self == user
          result.merge!(as_protected_json(options))
        end

        result.merge!(as_safe_json(options))
        result
      end

      protected

      def set_handles
        case provider
        when 'twitter'
          self.twitter = handle
        when 'github'
          self.github  = handle
        end
      end

      def set_secret
        self.secret ||= SecureRandom.hex(32)
      end

      def set_invites_count
        self.invites_count ||= 5
      end

      def recent?
        created_at && created_at >= 10.seconds.ago
      end

      def as_protected_json(options = nil)
        {
          email: email,
          recent: recent?,
          invites_count: invites_count,
          manifesto: manifesto,
          admin: admin?
        }
      end

      def as_safe_json(options = nil)
        {
          id: id,
          handle: handle,
          name: name,
          url: url,
          twitter: twitter,
          github: github,
          about: about,
          karma: karma,
          avatar_url: avatar_url,
          created_at: created_at
        }
      end

      def check_invite!
        invite = UserInvite.pending.matching(
          email:   email,
          twitter: twitter,
          github:  github
        ).first

        activate!(invite) if invite
      end

      def auth_info
        auth && auth[:info] || {}
      end
    end
  end
end