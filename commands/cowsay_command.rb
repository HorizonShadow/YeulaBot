module Commands
  class CowsayCommand
    class << self
      include Cowsay

      def name
        :cowsay
      end

      def middleware
        [
          OptionsParserMiddleware.new do |option_parser, options|
            options[:c] = "cow"

            option_parser.banner = "Usage: cowsay [options] text"

            option_parser.on("-l", "--list", "List available \"cows\"") do
              options[:l] = true
            end

            option_parser.on("-c", "--cow COW", "Specify a \"cow\"") do |cow|
              options[:c] = cow.capitalize
            end
          end
        ]
      end

      def attributes
        {
          description: "cowsay",
          usage: "cowsay",
          aliases: []
        }
      end

      # We are literally re-implementing the CLI for cowsay here
      # just to demonstrate the options parser
      # more or less copied from https://github.com/johnnyt/cowsay/blob/master/lib/cowsay.rb
      def command(event, *args)
        return if event.from_bot?
        
        options, *input = args


        if options[:l]
          output = "```"
          output << Cowsay.character_classes.join("\n") 
          output << "```"
        elsif Cowsay.character_classes.include? options[:c].to_sym
          output = "```"
          output << Cowsay.say(input.join(" "), options[:c])
          output << "```"
        else
          "No cow file found for #{options[:c]}. Use the -l flag to see a list of available cow files."
        end
      end
    end
  end
end