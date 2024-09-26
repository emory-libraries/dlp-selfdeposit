# frozen_string_literal: true
class User < ApplicationRecord
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Role-management behaviors.
  include Hydra::RoleManagement::UserRoles
  # Connects this user object to Hyrax behaviors.
  include Hyrax::User
  include Hyrax::UserUsageStats

  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :saml_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # temporary fix for SAML login while we have a hybrid login
  validates :password, presence: true, if: :password_required?

  def password_required?
    return false if saml_authenticatable?
    super
  end

  def saml_authenticatable?
    uid.present?
  end
  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.

  def to_s
    email
  end

  def self.from_saml(auth)
    return unless Rails.env.production?
    user = find_or_initialize_by(email: auth.info.mail)
    set_user_attributes(user, auth)

    if user.save
      user
    else
      log_saml_error(auth)
      User.new
    end
  end

  def self.log_saml_error(auth)
    if auth.info.mail.blank?
      Rails.logger.error "Nil user detected: SAML didn't pass an email for #{auth.inspect}"
    else
      Rails.logger.error "Failed to create/update user: #{auth.inspect}"
    end
  end
end

private

def set_user_attributes(user, auth)
  password = SecureRandom.hex(16)
  user.assign_attributes(
    display_name: auth.info.displayName,
    department: auth.info.ou,
    title: auth.info.title,
    uid: auth.uid,
    # set a random password temporarily to allow a hybrid login
    password:,
    password_confirmation: password
  )
end
