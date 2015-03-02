module HasToken
  extend ActiveSupport::Concern

  included do
    class_attribute :tokens, instance_writer: false
    self.tokens = {}
  end

  module ClassMethods
    # Inits the token and sets up some helper methods.
    #
    # Example:
    #
    #   class User < ActiveRecord::Base
    #     has_token :auth, 1.day
    #   end
    #
    #   User.tokens
    #   #=> {:auth=>Token (scope: :auth, ttl: 1 day)}
    #
    #   token = user.auth_token
    #   #=> "e56b56d394896edee56b56d394896edee56b56d394896ede"
    #
    #   user == User.find_by_auth_token(token)
    #   #=> true
    #
    #   user.valid_auth_token?(token)
    #   #=> true
    #
    # The find_by_{scope}_token method returns nil on error.
    def has_token(scope, ttl)
      tokens[scope] = Token.derive(scope, ttl)

      define_singleton_method("find_by_#{scope}_token") do |token|
        begin
          find_by_id(tokens[scope].from_s(token).id)
        rescue JWT::DecodeError, JWT::ExpiredSignature
          nil
        end
      end

      define_method("#{scope}_token") do
        tokens[scope].for(self).to_s
      end

      define_method("valid_#{scope}_token?") do |token|
        begin
          tokens[scope].from_s(token).id == id
        rescue JWT::DecodeError, JWT::ExpiredSignature
          false
        end
      end
    end
  end
end
