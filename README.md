# Shrine::Storage::Fog

Provides [Fog] storage for [Shrine].

Fog is an abstraction over a variety of cloud storages (e.g. Google Cloud and
Dropbox).

## Installation

```ruby
gem "shrine-fog", "~> 2.0"
gem "fog-xyz" # Fog gem for the storage you want to use
```

## Usage

Require the appropriate Fog gem, and assign the parameters for initializing
the storage:

```rb
require "shrine/storage/fog"
require "fog/google"

Shrine.storages[:store] = Shrine::Storage::Fog.new(
  provider: "Google",                                    #
  google_storage_access_key_id: "ACCESS_KEY_ID",         # Fog credentials
  google_storage_secret_access_key: "SECRET_ACCESS_KEY", #
  directory: "uploads",
)
```

You can also assign a Fog storage object as the `:connection`:

```rb
require "shrine/storage/fog"
require "fog/google"

google = Fog::Storage.new(
  provider: "Google",
  google_storage_access_key_id: "ACCESS_KEY_ID",
  google_storage_secret_access_key: "SECRET_ACCESS_KEY",
)

Shrine.storages[:store] = Shrine::Storage::Fog.new(
  connection: google,
  directory: "uploads",
)
```

If both cache and store are a Fog storage, the uploaded file is copied to store
instead of reuploaded.

### URLs

By default shrine-fog will generate signed expiring URLs.

```rb
uploaded_file.url("image.jpg") #=> "https://my-bucket.s3-eu-west-1.amazonaws.com/foo?X-Amz-Expires=3600&X-Amz-Date=20151217T102105Z&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIJF55TMZZY45UT6Q/20151217/eu-west-1/s3/aws4_request&X-Amz-SignedHeaders=host&X-Amz-Signature=6908d8cd85ce4469f141a36955611f26d29ae7919eb8a6cba28f9194a92d96c3"
```

You can modify the URL expiration date via `:expires` (the default is `3600`):

```rb
uploaded_file.url("image.jpg", expires: 90) #=> "https://my-bucket.s3-eu-west-1.amazonaws.com/foo?X-Amz-Expires=90&X-Amz-Date=20151217T102105Z&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIJF55TMZZY45UT6Q/20151217/eu-west-1/s3/aws4_request&X-Amz-SignedHeaders=host&X-Amz-Signature=6908d8cd85ce4469f141a36955611f26d29ae7919eb8a6cba28f9194a92d96c3"
```

If the files you're uploading are public readable (e.g. you're passing the
correct ACL on upload, `acl: "publicRead"` for fog-google), and you want to
generate public URLs, you can pass `public: true` to `#url`:

```rb
uploaded_file.url("image.jpg", public: true) #=> "https://my-bucket.s3-eu-west-1.amazonaws.com/image.jpg"
```

Any additional URL options will be forwarded directly to the provider's
`File#url` method.

You can use the `default_url_options` Shrine plugin to set default URL options.

### Upload options

Dynamic upload options can be passed via the `upload_options` plugin:

```rb
Shrine.plugin :upload_options, store: { acl: "publicRead" }
```

You can also specify default upload options on storage initialization:

```rb
Shrine::Storage::Fog.new(upload_options: { acl: "publicRead" }, **options)
```

### S3 or Filesystem

If you want to store your files to Amazon S3 or the filesystem, you should use
the storages that ship with Shrine (instead of [fog-aws] or [fog-local]) as
they are much more advanced.

## Running tests

Tests use [fog-aws], so you'll have to create an `.env` file with appropriate
credentials:

```sh
# .env
S3_ACCESS_KEY_ID="..."
S3_SECRET_ACCESS_KEY="..."
S3_REGION="..."
S3_BUCKET="..."
```

Afterwards you can run the tests:

```sh
$ bundle exec rake test
```

## Inspiration

This gem was inspired by [refile-fog].

## License

[MIT](http://opensource.org/licenses/MIT)

[Fog]: http://fog.io/
[Shrine]: https://github.com/shrinerb/shrine
[fog-aws]: https://github.com/fog/fog-aws
[fog-local]: https://github.com/fog/fog-local
[refile-fog]: https://github.com/refile/refile-fog
