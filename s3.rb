# Usage:
#        S3.upload(contents: 'file_body',
#                  bucket: 'random',
#                  file: 'file.txt',
#                  append_to_file: false)

require 'fog'

module S3
  S3_CREDENTIALS = {
    bucket: ENV['S3_BUCKET'],
    bucket_url: "https://s3.amazonaws.com/#{bucket}",
    access_key_id: ENV['AWS_ACCESS_KEY_ID'],
    secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
  }.freeze

  def self.upload(contents: contents,
                  bucket: bucket, file: file,
                  append_to_file: append_to_file = true)

    connection = initiate_connection
    directory = connection.directories.get bucket

    if directory.nil?
      raise "Bucket #{bucket} does not exist. You must create one before"\
            ' uploading to it.'
    end

    file_opts = {
      key: file,
      body: contents,
      public: false,
      bucket_name: bucket
    }

    file = directory.files.get(file) || directory.files.create(file_opts)
    file_contents = append_to_file ? file.body : ''
    file.body = file_contents + contents
    file.save
    file
  end

  def self.retrieve_file(bucket: bucket, file: file)
    retrieve_bucket(bucket: bucket).files.get file
  end

  def self.retrieve_bucket(bucket: bucket)
    initiate_connection.directories.get bucket
  end

  def self.initiate_connection
    check_required

    Fog::Storage.new(
      provider: 'AWS',
      aws_access_key_id: S3_CREDENTIALS[:access_key_id],
      aws_secret_access_key: S3_CREDENTIALS[:secret_access_key],
      path_style: true
    )
  end

  def check_required
    if (!defined?(S3_CREDENTIALS) ||
        S3_CREDENTIALS[:access_key_id].nil? ||
        S3_CREDENTIALS[:secret_access_key].nil?)

      raise 'S3_CREDENTIALS, S3_CREDENTIALS[:access_key_id], and '\
            'S3_CREDENTIALS[:secret_access_key] must be defined'
    end
  end
end
