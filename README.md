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

## S3 or Filesystem

If you want to store your files to Amazon S3 or the filesystem, you should use
the storages that ship with Shrine (instead of [fog-aws] or [fog-local]) as
they are much more advanced.

## License

[MIT](http://opensource.org/licenses/MIT)

[Fog]: http://fog.io/
[Shrine]: https://github.com/janko-m/shrine
[fog-aws]: https://github.com/fog/fog-aws
[fog-local]: https://github.com/fog/fog-local
