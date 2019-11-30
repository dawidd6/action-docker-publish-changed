#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'octokit'

path = ENV['GITHUB_EVENT_PATH']
repo = ENV['GITHUB_REPOSITORY']
token = ENV['INPUT_GITHUB_TOKEN']
username = ENV['INPUT_DOCKER_USERNAME']
password = ENV['INPUT_DOCKER_PASSWORD']
tag = "latest"
file = File.read(path)
json = JSON.parse(file)
client = Octokit::Client.new(access_token: token)
images = json['commits'].map do |commit|
  commit = client.commit(repo, commit['id'])
  changed_images(commit)
end.flatten

def safe_system(*cmd)
  exit 1 unless system(*cmd)
end

images.each do |image|
  puts "==> Building \"#{image}\" image"
  safe_system('docker', 'login', '-u', username, '-p', password)
  safe_system('docker', 'build', '-t', "#{username}/#{image}:#{tag}", image)
  safe_system('docker', 'push', "#{username}/#{image}:#{tag}")
end
