# == Schema Information
#
# Table name: user_reaction_servers
#
#  id               :bigint           not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  server_id        :bigint           not null
#  user_reaction_id :bigint           not null
#
# Indexes
#
#  index_user_reaction_servers_on_server_id         (server_id)
#  index_user_reaction_servers_on_user_reaction_id  (user_reaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_reaction_id => user_reactions.id)
#
require "test_helper"

class UserReactionServerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
