# == Schema Information
#
# Table name: user_servers
#
#  id         :bigint           not null, primary key
#  owner      :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  server_id  :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_servers_on_server_id  (server_id)
#  index_user_servers_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (server_id => servers.id)
#  fk_rails_...  (user_id => users.id)
#
require "test_helper"

class UserServerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
