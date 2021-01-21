class TwitchStream < ApplicationRecord
  def expired?
    Time.now > expires_at
  end

  def renew
    return unless expired?
    
    Apis::Twitch.subscribe(twitch_user_id, server)
    update(expires_at: Time.now + Apis::Twitch.lease_time)
  end
end