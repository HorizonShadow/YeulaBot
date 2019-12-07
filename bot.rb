require 'active_record'
require 'discordrb'
require 'google/apis/customsearch_v1'
require 'google/apis/youtube_v3'
require 'google/apis/translate_v2'
require 'redd'
require 'require_all'
require 'csv'
require 'rufus-scheduler'
require 'faye/websocket'
require 'byebug'
require 'mtg_sdk'
require 'mini_racer'
require 'octokit'
require 'dotenv/load'
require 'timeout'
require 'steam-api'
require 'nokogiri'

require_relative 'models/application_record'
require_all './models'
require_all './commands'
require_all './lib'
require_all './new_commands'
require_all './reactions'
require_all './routines'
require_all './room-17-proxy'

include Routines

ActiveRecord::Base.configurations = YAML::load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(ENV['RACK_ENV']&.to_sym || :development)

unless ENV['discord']
    abort "You're missing your discord API token! put discord=<your token here> in a .env file"
end

BOT = Discordrb::Commands::CommandBot.new({
    token: ENV['discord'],
    prefix: '!!',
    log_level: :debug,
    parse_self: true
})

User.where(banned: true).each do |user|
  BOT.ignore_user user.id
end

if ENV['admins']
    ENV['admins'].split(',').each do |admin|
        BOT.set_user_permission(admin.to_i, 1)
    end
end

Afk.destroy_all
UserCommand.all.each do |command|
  BOT.command(command.name.to_sym, &command.method(:run))
end

BOT.command(:ping) do |event|
  event.respond "pong"
end

Commands.constants.map do |c|
  command = Commands.const_get(c)
  command.is_a?(Class) ? command : nil
end.compact.each do |command|
  BOT.command(command.name, command.attributes, &command.method(:command))
end

Reactions.constants.map do |r|
  reaction = Reactions.const_get(r)
  reaction.is_a?(Class) ? reaction : nil
end.compact.each do |reaction|
  BOT.message(reaction.attributes, &reaction.method(:command))
end

BOT.message_edit(&method(:archive_routine))

BOT.message do |event|
  next if event.from_bot?

  message = event.message.content
  name = message.match(/!!(.+?) /)[1]

  command = NewCommands.constants.map do |c|
    command = NewCommands.const_get(c)
    command.is_a?(Class) ? command : nil
  end.compact.select do |command|
    p command.name, name
    command.name.to_s == name
  end.first
  p command
  command.new(event).run(message) if command

  urs = UserReaction.all.select do |ur|
    Regexp.new(ur.regex).match event.message.content
  end
  urs.each do |ur|
    if rand <= ur.chance
      event.respond(event.message.content.sub(/#{ur.regex}/, ur.output))
    end
  end

  user_ids = event.message.mentions.map(&:id)
  user_ids.each do |uid|
    user = User.find_by(id: uid)
    if user&.afk
      out = ''
      out << "#{user.name} is afk"
      out << ": #{user.afk.message}" if user.afk.message
      event << out
    end
  end
end

scheduler = Rufus::Scheduler.new
scheduler.every '1d', first: :now do
  birthday_routine(BOT)
end