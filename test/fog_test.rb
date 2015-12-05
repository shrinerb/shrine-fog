require "test_helper"
require "shrine/storage/linter"

describe Shrine::Storage::Fog do
  def fog(**options)
    options[:provider]              ||= "AWS"
    options[:aws_access_key_id]     ||= ENV.fetch("S3_ACCESS_KEY_ID")
    options[:aws_secret_access_key] ||= ENV.fetch("S3_SECRET_ACCESS_KEY")
    options[:region]                ||= ENV.fetch("S3_REGION")
    options[:directory]             ||= ENV.fetch("S3_BUCKET")

    Shrine::Storage::Fog.new(**options)
  end

  before do
    @fog = fog
    shrine = Class.new(Shrine)
    shrine.storages = {fog: @fog}
    @uploader = shrine.new(:fog)
  end

  after do
    @fog.clear!(:confirm)
  end

  it "passes the linter" do
    Shrine::Storage::Linter.call(fog)
    Shrine::Storage::Linter.call(fog(prefix: "prefix"))
  end

  describe "#upload" do
    it "assigns the content type" do
      @fog.upload(fakeio, "foo", {"mime_type" => "image/jpeg"})
      tempfile = @fog.download("foo")

      assert_equal "image/jpeg", tempfile.content_type
    end

    it "copies the file if it's from the same storage" do
      uploaded_file = @uploader.upload(fakeio, location: "foo")
      @fog.upload(uploaded_file, "bar")

      assert @fog.exists?("bar")
    end
  end
end
