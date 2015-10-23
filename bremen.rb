#!/usr/local/bin/ruby

require 'rubygems'
gem 'google-api-client', '>0.7'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/file_storage'
require 'google/api_client/auth/installed_app'
require 'trollop'

# This OAuth 2.0 access scope allows for full read/write access to the
# authenticated user's account.
YOUTUBE_SCOPE = 'https://www.googleapis.com/auth/youtube'
YOUTUBE_API_SERVICE_NAME = 'youtube'
YOUTUBE_API_VERSION = 'v3'

$PROGRAM_NAME = 'bremen'

def get_authenticated_service
  client = Google::APIClient.new(
    :application_name => $PROGRAM_NAME,
    :application_version => '1.0.0'
  )
  youtube = client.discovered_api(YOUTUBE_API_SERVICE_NAME, YOUTUBE_API_VERSION)

  file_storage = Google::APIClient::FileStorage.new("#{$PROGRAM_NAME}-oauth2.json")
  if file_storage.authorization.nil?
    client_secrets = Google::APIClient::ClientSecrets.load
    flow = Google::APIClient::InstalledAppFlow.new(
      :client_id => client_secrets.client_id,
      :client_secret => client_secrets.client_secret,
      :scope => [YOUTUBE_SCOPE]
    )
    client.authorization = flow.authorize(file_storage)
  else
    client.authorization = file_storage.authorization
  end

  return client, youtube
end

def main(video_id)
  client, youtube = get_authenticated_service

  begin
    body = {
      :snippet => {
        :playlistId => 'PLK1195uQQBV0I2PgMKFn8CxdtHTcrP_cC',
        :resourceId => {
          :videoId => video_id,
          :kind => 'youtube#video'
        }
      }
    }

    # Call the youtube.activities.insert method to post the channel bulletin.
    client.execute!(
      :api_method => youtube.playlist_items.insert,
      :parameters => {
        :part => body.keys.join(',')
      },
      :body_object => body
    )

    puts "The bulletin was posted to your channel."
  rescue Google::APIClient::TransmissionError => e
    puts e.result.body
  end
end

begin
  video_id = ARGV.first
  main(video_id)
rescue => ex
  File.open('error_log', 'a') {|f| f.puts ex}
end


