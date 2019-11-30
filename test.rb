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

    expected = %w[
      test-image
      image-name
    ]
    got = changed_images(JSON.parse(commit))

    assert_equal(expected, got)
  end
end
