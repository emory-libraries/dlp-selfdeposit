# frozen_string_literal: true
# [Hyrax-override-v5.1 (ec2c524)] Hyrax Bug!
#   Bug ticket filed: https://github.com/samvera/hyrax/pull/7120

Rails.application.config.to_prepare do
  Hyrax::FileSetsController.class_eval do
    private

    def cast_file_set
      return unless @file_set.class == ::FileSet
      # We can tell if a Hyrax::FileSet was improperly cast because this AF method will
      # return nil since its parent is not a ActiveFedora work.
      @file_set = @file_set.valkyrie_resource if @file_set.respond_to?(:parent) && @file_set.parent&.id.nil?
    end
  end
end
