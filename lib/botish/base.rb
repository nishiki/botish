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

module Botish
  class Base
    def initialize(connection)
      @connection = connection
    end

    def run(args) end

    private

    def send_msg(msg)
      log("-> #{msg}")
      @connection.puts(msg)
    end

    def log(msg)
      puts "#{Time.now.strftime('%Y-%m-%d %H:%M:%S.%L')} #{msg}"
    end
  end
end
