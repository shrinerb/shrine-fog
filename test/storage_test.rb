require "test_helper"
require "shrine/storage/linter"

describe Shrine::Storage::Fog do
  def storage(**options)
    options[:provider]              ||= "AWS"
    options[:aws_access_key_id]     ||= ENV.fetch("S3_ACCESS_KEY_ID")
    options[:aws_secret_access_key] ||= ENV.fetch("S3_SECRET_ACCESS_KEY")
    options[:region]                ||= ENV.fetch("S3_REGION")
    options[:directory]             ||= ENV.fetch("S3_BUCKET")

    Shrine::Storage::Fog.new(**options)
  end

  before do
    @storage = storage
    shrine = Class.new(Shrine)
    shrine.storages = {fog: @storage}
    @uploader = shrine.new(:fog)
  end

  after do
    @storage.clear!(:confirm)
  end

  it "passes the linter" do
    Shrine::Storage::Linter.call(storage)
    Shrine::Storage::Linter.call(storage(prefix: "prefix"))
  end

  describe "#upload" do
    it "assigns the content type" do
      @storage.upload(fakeio, "foo", {"mime_type" => "image/jpeg"})
      tempfile = @storage.download("foo")

      assert_equal "image/jpeg", tempfile.content_type
    end

    it "copies the file if it's from the same storage" do
      uploaded_file = @uploader.upload(fakeio, location: "foo")
      @storage.upload(uploaded_file, "bar")

      assert @storage.exists?("bar")
    end
  end
end
