module Brisk
  module Models
    class UserInvite < Sequel::Model
      many_to_one :user
      many_to_one :invited_user, :class => 'Brisk::Models::User'

      dataset_module do
        def pending
          where(:invited_user_id => nil)
        end

        def matching(attrs = {})
          where(
            {~:email => nil, :email => attrs[:email]} |
            {~:twitter => nil, :twitter => attrs[:twitter]} |
            {~:github => nil, :github => attrs[:github]}
          )
        end
      end

      set_allowed_columns :email, :twitter, :github

      def validate
        set_code
        strip_atmarks
        validates_presence [:code, :user_id]
        validates_invite_type
      end

      def notify!
        if email.present?
          Mailer.user_invite!(self)
        end
      end

      def use!(invited_user)
        return false unless pending?
        update_all(invited_user: invited_user)
        user.add_child(invited_user)
        true
      end

      def pending?
        !invited_user_id
      end

      def pending_matching_user
        User.pending.matching(values).first
      end

      def active_matching_user
        User.active.matching(values).first
      end

      def similar_invite
        invite = self.class.matching(values)
        invite = invite.where(user_id: user_id)
        invite = invite.where(~:id => self.id)
        invite.first
      end

      def user_name
        user && user.name
      end

      def invited_user_name
        invited_user && invited_user.name
      end

      def as_json(options = nil)
        {
          id: id,
          user_name: user_name,
          invited_user_name: invited_user_name,
          code: code,
          created_at: created_at
        }
      end

      protected

      def validates_invite_type
        unless email.present? || twitter.present? || github.present?
          errors.add(:base, 'must specify email or twitter or github')
        end
      end

      def set_code
        self.code ||= SecureRandom.hex(6)
      end

      def strip_atmarks
        self.twitter.gsub!(/@/, '') if self.twitter
        self.github.gsub!(/@/, '') if self.github
      end
    end
  end
end