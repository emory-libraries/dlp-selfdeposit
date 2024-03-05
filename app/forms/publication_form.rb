# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work_resource Publication`
#
# @see https://github.com/samvera/hyrax/wiki/Hyrax-Valkyrie-Usage-Guide#forms
# @see https://github.com/samvera/valkyrie/wiki/ChangeSets-and-Dirty-Tracking
class PublicationForm < Hyrax::Forms::PcdmObjectForm(Publication)
  include Hyrax::FormFields(:emory_basic_metadata)
  include Hyrax::FormFields(:publication_metadata)

  # Define custom form fields using the Valkyrie::ChangeSet interface
  #
  # property :my_custom_form_field

  # if you want a field in the form, but it doesn't have a directly corresponding
  # model attribute, make it virtual
  #
  # property :user_input_not_destined_for_the_model, virtual: true
end
