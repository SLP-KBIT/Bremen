#!/usr/local/bin/ruby

require 'cgi'

cgi = CGI.new
puts cgi.header(charset: 'utf-8')

video_id = cgi['text'].split('?v=').last.chop

system "bundle exec ruby bremen.rb #{video_id}"

