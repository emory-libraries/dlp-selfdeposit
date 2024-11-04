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
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:saml]
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
    email = auth.info.net_id + '@emory.edu' unless auth.info.net_id == 'tezproxy'
    where(email: email, uid: auth.info.net_id).first_or_create do |user|
      user.email = email
      user.display_name = auth.info.displayName
      user.department = auth.info.ou
      user.title = auth.info.title
      user.password = SecureRandom.hex(16)
      user.password_confirmation = user.password
    end
    user
  end
end
