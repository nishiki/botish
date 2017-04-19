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

require 'json'
require 'net/http'
require 'botish/base'

module Botish
  module Plugin
    class Wikipedia < Base
      def run(args)
        params = {
          format:   'json',
          action:   'query',
          list:     'search',
          utf8:      true,
          srsearch:  args[:args]
        }
        uri       = URI('https://fr.wikipedia.org/w/api.php')
        uri.query = URI.encode_www_form(params)

        data      = JSON.parse(Net::HTTP.get(uri))['query']['search'][0]
        title     = data['title']
        url       = URI.encode("https://fr.wikipedia.org/wiki/#{title.tr(' ', '_')}")

        send_msg("PRIVMSG #{args[:channel]} :#{args[:user]}: #{data['title']} => #{url}")
      end
    end
  end
end
