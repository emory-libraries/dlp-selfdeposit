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
  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    email
  end

  def self.from_saml(auth)
    return unless Rails.env.production?
    user = find_or_initialize_by(email: auth.info.mail)

    user.assign_attributes(
      display_name: auth.info.displayName,
      department: auth.info.ou,
      title: auth.info.title,
      uid: auth.uid
    )

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
