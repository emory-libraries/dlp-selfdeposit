# frozen_string_literal: true
class Ability
  include Hydra::Ability

  include Hyrax::Ability
  self.ability_logic += [:everyone_can_create_curation_concerns]

  # Define any customized permissions here.
  def custom_permissions
    return unless current_user.admin?
    can [:create, :show, :add_user, :remove_user, :index, :edit, :update, :destroy], Role
  end

  def can_import_works?
    admin?
  end

  def can_export_works?
    admin?
  end
end
