#!/usr/bin/env ruby
# frozen_string_literal: true

require 'test/unit'
require 'json'
require_relative 'lib.rb'

class ChangedImagesTest < Test::Unit::TestCase
  def test_changed_images
    commit = <<~ELO
      {
        "files": [
          {
            "filename": "test-image/Dockerfile",
            "status": "added"
          }, {
            "filename": "test-image/Dockerfile",
            "status": "modified"
          }, {
            "filename": "test-image/Dockerfile",
            "status": "removed"
          }, {
            "filename": "Dockerfile",
            "status": "added"
          }, {
            "filename": "README.md",
            "status": "modified"
          }, {
            "filename": ".github/workflows/test.yml",
            "status": "modified"
          }, {
            "filename": "hello/there/image-name/Dockerfile",
            "status": "modified"
          }, {
            "filename": "deleted-image/Dockerfile",
            "status": "removed"
          }, {
            "filename": "do/not/capture",
            "status": "modified"
          }, {
            "filename": "src/.gitignore",
            "status": "added"
          }, {
            "filename": "node_modules/something",
            "status": "added"
          }, {
            "filename": "go.mod",
            "status": "added"
          }, {
            "filename": "first/second/image-next/Dockerfile",
            "status": "added"
          }
        ]
      }
    ELO

    expected = %w[
      test-image
      image-name
      image-next
    ]
    got = changed_images(JSON.parse(commit))

    assert_equal(expected, got)
  end
end
