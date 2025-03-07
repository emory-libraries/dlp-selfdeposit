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
  devise_modules = [:recoverable, :rememberable, :omniauthable, omniauth_providers: [:saml]]
  devise_modules.prepend(:database_authenticatable, :registerable) # if AuthConfig.use_database_auth?
  devise(*devise_modules)

  validates :email, presence: true, format: { with: Devise.email_regexp }
  validates :password, presence: true, if: :password_required?

  def password_required?
    return false if saml_authenticatable?
  
    !persisted? || !password.nil? || !password_confirmation.nil? || encrypted_password.blank?
  end

  def saml_authenticatable?
    provider == 'saml'
  end

  def to_s
    email
  end

  def self.from_omniauth(auth)
    if auth.info.ppid.nil? || auth.provider != 'saml'
      log_omniauth_error(auth)
      return User.new
    end

    begin
      user = find_by!(provider: auth.provider, ppid: auth.info.ppid)
    rescue ActiveRecord::RecordNotFound
      user = User.new
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
    if auth.info.ppid.nil?
      Rails.logger.error "Nil user detected: SAML didn't pass a ppid for #{auth.inspect}"
    elsif auth.provider != 'saml'
      Rails.logger.error "Invalid provider attempted login: #{auth.provider} for #{auth.inspect}"
    else
      Rails.logger.error "Unauthorized user attempted login: #{auth.inspect}"
    end
  end
end
