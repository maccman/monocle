require 'digest/md5'

module Gravatar extend self
  def url(email)
    hex = Digest::MD5.hexdigest(email.downcase)
    "https://secure.gravatar.com/avatar/#{hex}/?s=66&d=monsterid"
  end
end