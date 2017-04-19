#!/usr/bin/ruby

require 'yaml'
require 'socket'
require 'botish/base'

module Botish
  class Botish < Base
    def initialize(config_file)
      config    = YAML.load_file(config_file)
      @host     = config['host']
      @channels = config['channels']
      @user     = config['user'] || 'botish'
      @port     = config['port'] || 6667
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

      @channels.each do |channel|
        send_msg("JOIN ##{channel}")
        send_msg("PRIVMSG ##{channel} :Je suis là :')")
      end
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

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG (?<channel>#[[:alpha:]]+) :#{@user}: ping/
        send_msg("PRIVMSG #{Regexp.last_match('channel')} :#{Regexp.last_match('user')}: pong")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG (?<channel>#?[[:alpha:]]+) :#{@user}: (?<command>[[:lower:]]+)( (?<args>.+))?/
        command = Regexp.last_match('command')
        options =
          %i[user channel args].each_with_object({}) do |key, opts|
            opts[key] = Regexp.last_match(key)
          end

        plugin_class = "Botish::Plugin::#{command.capitalize}"
        if Object.const_defined?(plugin_class)
          Object.const_get(plugin_class).new(@connection).run(options)
        else
          send_msg("PRIVMSG #{options[:channel]} :#{options[:user]}: unknown command")
        end
      end
    end
  end
end
