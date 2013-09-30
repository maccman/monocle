module Brisk
  module Models
    class Comment < Sequel::Model
      many_to_one :post
      many_to_one :user

      one_to_many :comment_votes, :on_delete => :cascade

      many_to_many :voted_users,
                   :join_table => :comment_votes,
                   :class      => 'Brisk::Models::User',
                   :left_key   => :comment_id,
                   :right_key  => :user_id

      many_to_one :parent, :class => self
      one_to_many :children, :class => self, :key => :parent_id

      set_allowed_columns :body, :parent_id, :post_id

      dataset_module do
        def root
          where(:parent_id => nil)
        end

        def ordered
          order(:created_at.desc)
        end

        def for_user(user)
          where(:user_id => user.id)
        end
      end

      def vote!(user)
        if voted?(user) and !user.admin?
          raise Sequel::ValidationFailed, 'User already voted'
        end

        self.add_voted_user(user)
        self.this.update(:votes => :votes + 1)
        self.user.karma!

        reload
        calculate_score
        save
      end

      def voted?(user)
        voted_user_ids.include?(user.id)
      end

      def validate
        validates_presence [:post_id, :user_id, :body]
      end

      def avatar_url
        user && user.avatar_url
      end

      def user_handle
        user && user.handle
      end

      def user_name
        user && user.name
      end

      def formatted_body
        html = RDiscount.new(
          body,
          :filter_html, :filter_styles,
          :autolink, :safelink,
          :no_pseudo_protocols,
          :no_tables, :no_image
        ).to_html

        Sanitize.clean(
          html,
          Sanitize::Config::BASIC
        )
      end

      def as_json(options = nil)
        options ||= {}
        user      = options[:user]
        threaded  = options[:threaded]

        result = {
          id:             id,
          votes:          votes,
          voted:          user && voted?(user),
          score:          score,
          user_handle:    user_handle,
          user_id:        user_id,
          post_id:        post_id,
          parent_id:      parent_id,
          avatar_url:     avatar_url,
          body:           body,
          formatted_body: formatted_body,
          created_at:     created_at
        }

        if threaded
          result.merge!(children: children)
        end

        result
      end

      alias_method :karma, :votes

      protected

      def voted_user_ids
        voted_users.map(&:id)
      end

      def calculate_score
        order = Math.log([votes.abs, 1].max, 1.2)
        seconds    = (created_at || Time.now).to_i
        self.score = (order + seconds/45000).round(7)
      end
    end
  end
end