# frozen_string_literal: true
# To assign workflow reponsibilities to approved Users, run:
#   rake selfdeposit:assign_necessary_users_to_emory_mediated_deposit

namespace :selfdeposit do
  desc "Assigns approved Users managing capabilities for typical Users' deposit workflow"
  task assign_necessary_users_to_emory_mediated_deposit: :environment do
    AssignNecessaryUsersToEmoryMediatedDepositJob.perform_later
  end
end
