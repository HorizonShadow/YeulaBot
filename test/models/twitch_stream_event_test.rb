# == Schema Information
#
# Table name: twitch_stream_events
#
#  id             :bigint           not null, primary key
#  data           :json
#  server         :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  twitch_user_id :integer
#
require "test_helper"

class TwitchStreamEventTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
