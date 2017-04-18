#!/usr/bin/ruby

require 'socket'
require 'botish/base'

module Botish
  class Botish < Base
    HOST = 'irc.freenode.net'
    PORT = 6667
    USERNAME = 'botish'
    CHANNEL = '#testnishiki'

    def initialize
      @connection = TCPSocket.open(HOST, PORT)

      send_msg("NICK #{USERNAME}")
      send_msg("USER #{USERNAME} localhost * :#{USERNAME}")
      Kernel.loop do
        msg = @connection.gets
        log("<- #{msg}")
        break if msg.include?('End of /MOTD command.')
      end
      send_msg("JOIN #{CHANNEL}")
      send_msg("PRIVMSG #{CHANNEL} :Je suis là :')")
    end

    def listen
      Kernel.loop do
        msg = @connection.gets
        log("<- #{msg}")
        parse(msg)
      end
    end

    private

    def parse(msg)
      case msg
      when /^PING (?<host>.+)/
        send_msg("PONG #{Regexp.last_match('host')}")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG #{CHANNEL} :#{USERNAME}: ping/
        send_msg("PRIVMSG #{CHANNEL} :#{Regexp.last_match('user')}: pong")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG (?<channel>#?[[:alpha:]]+) :#{USERNAME}: (?<command>[[:lower:]]+)( (?<args>.+))?/
        command = Regexp.last_match('command')
        options =
          %i[user channel args].each_with_object({}) do |key, opts|
            opts[key] = Regexp.last_match(key)
          end

        plugin_class = "Botish::#{command.capitalize}"
        if Object.const_defined?(plugin_class)
          Object.const_get(plugin_class).new(@connection).run(options)
        else
          send_msg("PRIVMSG #{args[:channel]} :#{args[:user]}: unknown command")
        end
      end
    end
  end
end
