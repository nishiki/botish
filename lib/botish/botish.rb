#!/usr/bin/ruby

require 'socket'
require 'botish/base'

module Botish
  class Botish < Base
    def initialize(host, channel, user, port)
      @host       = host
      @channel    = channel
      @user       = user || 'botish'
      @port       = port || 6667
    end

    def connect
      @connection = TCPSocket.open(@host, @port)

      send_msg("NICK #{@user}")
      send_msg("USER #{@user} localhost * :#{@user}")

      Kernel.loop do
        msg = @connection.gets
        log("<- #{msg}")
        break if msg.include?('End of /MOTD command.')
      end

      send_msg("JOIN #{@channel}")
      send_msg("PRIVMSG #{@channel} :Je suis là :')")
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

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG #{@channel} :#{@user}: ping/
        send_msg("PRIVMSG #{@channel} :#{Regexp.last_match('user')}: pong")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG (?<channel>#?[[:alpha:]]+) :#{@user}: (?<command>[[:lower:]]+)( (?<args>.+))?/
        command = Regexp.last_match('command')
        options =
          %i[user channel args].each_with_object({}) do |key, opts|
            opts[key] = Regexp.last_match(key)
          end

        plugin_class = "Botish::#{command.capitalize}"
        if Object.const_defined?(plugin_class)
          Object.const_get(plugin_class).new(@connection).run(options)
        else
          send_msg("PRIVMSG #{options[:channel]} :#{options[:user]}: unknown command")
        end
      end
    end
  end
end
