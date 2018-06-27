require "test_helper"
require "shrine/storage/linter"
require "uri"
require "down/http"

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
    @fog.clear!
  end

  it "passes the linter" do
    Shrine::Storage::Linter.call(fog)
  end

  it "passes the linter with prefix" do
    Shrine::Storage::Linter.call(fog(prefix: "prefix"))
  end

  describe "#upload" do
    it "assigns the content type" do
      @fog.upload(fakeio, "foo", shrine_metadata: {"mime_type" => "image/jpeg"})
      tempfile = Down::Http.download(@fog.url("foo"))

      assert_equal "image/jpeg", tempfile.content_type
    end

    it "copies the file if it's from the same storage" do
      uploaded_file = @uploader.upload(fakeio, location: "foo")
      @fog.upload(uploaded_file, "bar")

      assert @fog.exists?("bar")
    end

    it "accepts upload options" do
      @fog.upload(fakeio, "foo", content_type: "image/jpeg")
      tempfile = Down::Http.download(@fog.url("foo"))

      assert_equal "image/jpeg", tempfile.content_type
    end

    it "applies default upload options" do
      @fog = fog(upload_options: { content_type: "image/jpeg" })
      @fog.upload(fakeio, "foo")
      tempfile = Down::Http.download(@fog.url("foo"))

      assert_equal "image/jpeg", tempfile.content_type
    end
  end

  describe "#open" do
    it "accepts additional parameters" do
      @fog.upload(fakeio, "foo")
      io = @fog.open("foo", rewindable: false)
      assert_raises(IOError) { io.rewind }
    end
  end

  describe "#url" do
    it "generates signed URLs by default" do
      assert_includes @fog.url("foo"), "X-Amz-Expires=3600"
    end

    it "can change URL expiration" do
      assert_includes @fog.url("foo", expires: 90), "X-Amz-Expires=90"
    end

    it "can generate public URLs" do
      url = @fog.url("foo", public: true)
      assert_nil URI.parse(url).query
    end

    it "accepts additional URL options" do
      assert_includes @fog.url("foo", headers: { foo: "bar" }), "X-Amz-SignedHeaders=foo"
    end
  end
end
