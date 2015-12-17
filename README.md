# Shrine::Fog

Provides [Fog] storage for [Shrine].

## Installation

```ruby
gem "shrine-fog"
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

By default the shrine-fog will generate public unsigned URLs, but if you want
to change that tell Fog not to store files publicly, you can set `:public` to
false:

```rb
fog = Shrine::Storage::Fog.new(**fog_options)
fog.url("image.jpg") #=> "https://my-bucket.s3-eu-west-1.amazonaws.com/image.jpg"

fog = Shrine::Storage::Fog.new(public: false, **fog_options)
fog.url("image.jpg") #=> "https://my-bucket.s3-eu-west-1.amazonaws.com/foo?X-Amz-Expires=3600&X-Amz-Date=20151217T102105Z&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIJF55TMZZY45UT6Q/20151217/eu-west-1/s3/aws4_request&X-Amz-SignedHeaders=host&X-Amz-Signature=6908d8cd85ce4469f141a36955611f26d29ae7919eb8a6cba28f9194a92d96c3"
```

The signed URLs by default expire in 1 hour, you set `:expires` to number of
seconds you want the URL to expire:

```rb
Shrine::Storage::Fog.new(expires: 24*60*60, **fog_options) # expires in 1 day
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

## License

[MIT](http://opensource.org/licenses/MIT)

[Fog]: http://fog.io/
[Shrine]: https://github.com/janko-m/shrine
[fog-aws]: https://github.com/fog/fog-aws
[fog-local]: https://github.com/fog/fog-local
