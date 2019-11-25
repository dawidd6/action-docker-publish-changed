#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'octokit'

def dummy_check
  %w[
    test-image
    image-name
  ]
end

def dummy_event
  <<~ELO
    {
      "commits": [
        {
          "distinct": true,
          "id": "531f85e183425620732d21ae41a55aa9a3f5e961",
          "message": "test adding image"
        }
      ]
    }
  ELO
end

def dummy_commit
  <<~ELO
    {
      "files": [
        {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "test-image/Dockerfile",
          "status": "added",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "test-image/Dockerfile",
          "status": "modified",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "test-image/Dockerfile",
          "status": "removed",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "Dockerfile",
          "status": "added",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "README.md",
          "status": "modified",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": ".github/workflows/test.yml",
          "status": "modified",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "hello/there/image-name/Dockerfile",
          "status": "modified",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "deleted-image/Dockerfile",
          "status": "removed",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "do/not/capture",
          "status": "modified",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }, {
          "sha": "e69de29bb2d1d6434b8b29ae775ad8c2e48c5391",
          "filename": "src/.gitignore",
          "status": "added",
          "additions": 0,
          "deletions": 0,
          "changes": 0
        }
      ]
    }
  ELO
end

# Environment variables
testing = ENV["TESTING"]
path = ENV["GITHUB_EVENT_PATH"]
repo = ENV["GITHUB_REPOSITORY"]
token = ENV["INPUT_GITHUB_TOKEN"]
username = ENV["INPUT_DOCKER_USERNAME"]
password = ENV["INPUT_DOCKER_PASSWORD"]
whitelist = ENV["INPUT_WHITELIST"] || "Dockerfile"
tag = ENV["INPUT_TAG"] || "latest"

# Parse appropriate JSON object
event = JSON.parse(testing ? dummy_event : File.read(path))

# Initialize octokit
client = Octokit::Client.new(:access_token => token) unless testing

# Declare image names array
images = []

# Loop over all commits
event["commits"].each do |commit|
  # Parse appropriate JSON object
  commit = testing ? JSON.parse(dummy_commit) : client.commit(repo, commit["id"])

  # Loop over added files
  commit["files"].each do |file|
    # We do not want to build removed image
    # TODO think about removing the image from dockerhub
    next if file["status"] == "removed"

    # Get info
    image_path = file["filename"]
    image_name, image_file = image_path.split("/")[-2..-1]

    # Skip if conditions are not met
    next unless image_name
    next unless image_file
    next unless whitelist.split(",").include?(image_file)
    next if images.include?(image_name)

    # At last append
    images << image_name
  end
end

# Test or build and publish
if testing
  # Test
  if dummy_check.sort == images.sort
    puts "==> OK"
    puts images
  else
    puts "==> FAIL"
    exit 1
  end
else
  # Build and publish images
  images.each do |image|
    puts "==> Building \"#{image}\" image"
    exit 1 unless system("docker", "login", "-u", username, "-p", password)
    exit 1 unless system("docker", "build", "-t", "#{username}/#{image}:#{tag}", image)
    exit 1 unless system("docker", "push", "#{username}/#{image}:#{tag}")
  end
end

# Print images
puts "::set-output name=images::#{images.join(",")}"