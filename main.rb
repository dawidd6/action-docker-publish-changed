#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'octokit'
require_relative 'lib.rb'

path = ENV['GITHUB_EVENT_PATH']
repo = ENV['GITHUB_REPOSITORY']

token = ENV['INPUT_GITHUB_TOKEN']
username = ENV['INPUT_DOCKER_USERNAME']
password = ENV['INPUT_DOCKER_PASSWORD']
platforms = ENV['INPUT_PLATFORMS'] || 'linux/amd64'
tag = ENV['INPUT_TAG'] || 'latest'

file = File.read(path)
json = JSON.parse(file)
client = Octokit::Client.new(access_token: token)
images = json['commits'].map do |commit|
  commit = client.commit(repo, commit['id'])
  changed_images(commit)
end.flatten

safe_system('docker', 'login', '-u', username, '-p', password)
safe_system('docker', 'run', '--privileged', "docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d")
safe_system('buildx', 'create', '--use', '--name', 'builder')
safe_system('buildx', 'inspect', '--bootstrap', 'builder')

images.each do |image|
  puts "------------------ BUILDING \"#{image}\" IMAGE ------------------"
  safe_system('buildx', 'build', '--push', '--platform', platforms, '-t', "#{username}/#{image}:#{tag}", image)
end
