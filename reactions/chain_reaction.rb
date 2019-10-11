module Reactions
  class ChainReaction
    class << self
      include Discordrb::Webhooks

      def attributes
        {
        }
      end

      def command(event)
        return if event.from_bot?
        @history ||= {}
        @history[event.channel.id] ||= {
          is_new: true,
          message: nil,
          count: 1
        }
        history = @history[event.channel.id]

        if history[:message]
          if event.message.content == history[:message].content
            history[:count] = history[:count] + 1
          else
            history[:count] = 1
            history[:is_new] = true
          end

          if history[:count] > 1
            if history[:is_new]
              history[:message].delete
              history[:is_new] = false
              event.message.delete
              history[:chain_message] = event.respond "#{event.message.content} x2"
            else
              event.message.delete
              history[:chain_message].edit "#{event.message.content} x#{history[:count]}"
            end
            if history[:count] > 3
              history[:chain_message].create_reaction "wow:490866749647093761"
            elsif history[:count] > 5
              history[:chain_message].create_reaction "a:partyhat:362504920517050369"
            elsif history[:count] > 7
              history[:chain_message].create_reaction "a:sharkdance:446727875291381760"
            end
          end
        end

        history[:message] = event.message
      end
    end
  end
end