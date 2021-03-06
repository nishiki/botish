#!/usr/bin/ruby
# Botish is an IRC bot
# Copyright (C) 2017  Adrien Waksberg <botish@yae.im>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

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

      Dir["#{config['plugins_dir']}/*"].each do |f|
        require_relative f
      end
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
