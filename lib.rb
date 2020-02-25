# frozen_string_literal: true

def changed_images(hash)
  hash['files'].map do |file|
    next if file['status'] == 'removed'
    next unless file['filename'].end_with?('Dockerfile')

    file['filename'].split('/')[-2]
  end.uniq.compact.reject(&:empty?)
end

def safe_system(*cmd)
  exit 1 unless system(*cmd)
end
