# frozen_string_literal: true
class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles

  include Hyrax::User
  include Hyrax::UserUsageStats

  class NilSamlUserError < RuntimeError
    attr_accessor :auth

    def initialize(message = nil, auth = nil)
      super(message)
      self.auth = auth
    end
  end

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise_modules = [:registerable, :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:saml]]
  devise_modules.prepend(:database_authenticatable) if AuthConfig.use_database_auth?
  devise(*devise_modules)

  # temporary fix for SAML login while we have a hybrid login
  validates :password, presence: true, if: :password_required?

  def password_required?
    return false if saml_authenticatable?
    super
  end

  def saml_authenticatable?
    provider == 'saml' && uid.present?
  end

  def to_s
    email
  end

  def self.from_omniauth(auth)
    begin
      user = find_by!(provider: auth.provider, uid: auth.info.net_id)
    rescue ActiveRecord::RecordNotFound
      log_omniauth_error(auth)
      return User.new
    end

    assign_user_attributes(user, auth)
    user.save
    user
  end

  def self.assign_user_attributes(user, auth)
    user.assign_attributes(
      display_name: auth.info.display_name,
      ppid: auth.uid
    )

    user.email = "#{auth.info.net_id}@emory.edu" unless auth.info.net_id == 'tezprox'
  end

  private_class_method :assign_user_attributes

  def self.log_omniauth_error(auth)
    if auth.info.net_id.blank?
      Rails.logger.error "Nil user detected: SAML didn't pass a net_id for #{auth.inspect}"
    else
      # Log unauthorized logins to error
      Rails.logger.error "Unauthorized user attempted login: #{auth.inspect}"
    end
  end
end

# Override a Hyrax class that expects to create system users with passwords.
# Since in production we're using shibboleth, and this removes the password
# methods from the User model, we need to override it.
module Hyrax::User
  module ClassMethods
    def find_or_create_system_user(user_key)
      u = ::User.find_or_create_by(uid: user_key)
      u.display_name = user_key
      u.email = "#{user_key}@example.com"
      u.password = ('a'..'z').to_a.shuffle(random: Random.new).join if AuthConfig.use_database_auth?
      u.save
      u
    end
  end
end
