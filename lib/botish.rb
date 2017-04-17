#!/usr/bin/ruby

require 'socket'

module Botish
  class Botish
    HOST = 'irc.freenode.net'
    PORT = 6667
    USERNAME = 'botish'
    CHANNEL = '#testnishiki'

    def initialize
      @connection = TCPSocket.open(HOST, PORT)

      forward("NICK #{USERNAME}")
      forward("USER #{USERNAME} localhost * :#{USERNAME}")
      Kernel.loop do
        msg = @connection.gets
        log("<- #{msg}")
        break if msg.include?('End of /MOTD command.')
      end
      forward("JOIN #{CHANNEL}")
      forward("PRIVMSG #{CHANNEL} :Je suis là :')")
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
        forward("PONG #{Regexp.last_match('host')}")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG #{CHANNEL} :#{USERNAME}: ping/
        forward("PRIVMSG #{CHANNEL} :#{Regexp.last_match('user')}: pong")

      when /^:(?<user>[[:alpha:]]+)([^ ]+)? PRIVMSG (?<channel>#?[[:alpha:]]+) :#{USERNAME}: (?<command>[[:lower:]]+)( (?<args>.+))?/
        command = Regexp.last_match('command')
        options =
          %i[user channel args].each_with_object({}) do |key, opts|
            opts[key] = Regexp.last_match(key)
          end

        Kernel.const_get("Botish::#{command.capitalize}").new(@connection, options)
      end
    end

    def forward(msg)
      log("-> #{msg}")
      @connection.puts(msg)
    end

    def log(msg)
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')} #{msg}"
    end
  end
end
