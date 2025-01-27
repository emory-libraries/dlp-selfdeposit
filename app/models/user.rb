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
  devise_modules.prepend(:database_authenticatable, :registerable) # if AuthConfig.use_database_auth?
  devise(*devise_modules)

  def to_s
    email
  end

  def self.from_omniauth(auth)
    begin
      user = find_by!(provider: auth.provider, ppid: auth.info.ppid)
    rescue ActiveRecord::RecordNotFound
      log_omniauth_error(auth)
      user = User.new
      if auth.info.role == 'Staff'
        assign_user_attributes(user, auth)
        user.save
        user
      end
    end

    assign_user_attributes(user, auth)
    user.save
    user
  end

  def self.assign_user_attributes(user, auth)
    user.assign_attributes(
      display_name: auth.info.display_name,
      ppid: auth.info.ppid,
      provider: auth.provider,
      uid: auth.info.net_id
    )

    user.email = "#{auth.info.net_id}@emory.edu" unless auth.info.net_id == 'tezprox'
  end

  def self.log_omniauth_error(auth)
    if auth.info.net_id.blank?
      Rails.logger.error "Nil user detected: SAML didn't pass a net_id for #{auth.inspect}"
    else
      # Log unauthorized logins to error
      Rails.logger.error "Unauthorized user attempted login: #{auth.inspect}"
    end
  end
end
