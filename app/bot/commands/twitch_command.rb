module Commands
  class TwitchCommand
    class << self
      def name
        :twitch
      end

      def options_parser
        @options_parser ||= OptionsParserMiddleware.new do |option_parser, options|
          option_parser.on("-c", "--config CHANNEL", "Specify the server to post streams in") do |channel|
            options[:channel] = channel
          end

          option_parser.on("-a", "--add NAME", "Add a stream to watch") do |name|
            options[:name] = name
          end

          option_parser.on("-r", "--remove NAME", "Remove an added stream") do |name|
            options[:remove] = name
          end

          option_parser.on("-l", "--list", "List all added streams") do
            options[:list] = true
          end

          option_parser.banner = "Usage: twitch [options]"
        end
      end

      def middleware
        [
          options_parser
        ]
      end

      def attributes
        {
          description: <<~USAGE,
            Twitch stream watcher
            #{options_parser.usage}
          USAGE
          aliases: []
        }
      end


      def command(event, *args)
        return if event.from_bot?

        options, *input = args

        if options[:channel]
          channel = options[:channel].match(/<#(\d+)>/)[1]
          if channel
            config = TwitchConfig.where(server: event.server.id).first_or_create
            config.update(channel: channel)
            event << "Twitch config updated"
          end
        end

        if options[:list]
          event << "The following streams are being tracked:"
          event << "```"
          TwitchStream.where(server: event.server.id).each do |twitch_stream|
            event << twitch_stream.twitch_login
          end
          event << "```"
        end

        if options[:remove]
          twitch_stream = TwitchStream.find_by(server: event.server.id, twitch_login: options[:remove])
          if twitch_stream
            user = Apis::Twitch.user(login: options[:remove])
            Apis::Twitch.unsubscribe(user["id"], event.server.id)
            twitch_stream.destroy
            event.respond "Stream #{options[:remove]} removed"
          else
            event.respond "No stream found for #{options[:remove]}"
          end
        end

        if options[:name] 
          user = Apis::Twitch.user(login: options[:name])
          Apis::Twitch.subscribe(user["id"], event.server.id)
          TwitchStream.where(server: event.server.id, twitch_login: options[:name], twitch_user_id: user["id"], expires_at: Time.now + Apis::Twitch.lease_time).first_or_create
          event << "Twitch stream added"
        end
      end
    end
  end
end
