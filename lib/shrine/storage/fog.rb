require "shrine"
require "down/http"
require "uri"

class Shrine
  module Storage
    class Fog
      attr_reader :connection, :directory, :prefix

      def initialize(directory:, prefix: nil, connection: nil, public_url: false, upload_options: {}, **options)
        @connection = connection || ::Fog::Storage.new(options)
        @directory = @connection.directories.new(key: directory)
        @prefix = prefix
        @public_url = public_url
        @upload_options = upload_options
      end

      def upload(io, id, **upload_options)
        if copyable?(io)
          copy(io, id, **upload_options)
        else
          put(io, id, **upload_options)
        end
      end

      def open(id, **options)
        Down::Http.open(url(id), **options)
      rescue Down::NotFound
        raise Shrine::FileNotFound, "file #{id.inspect} not found on storage"
      end

      def exists?(id)
        !!head(id)
      end

      def delete(id)
        file(id).destroy
      end

      def url(id, public: @public_url, expires: 3600, **options)
        signed_url = file(id).url(Time.now.utc + expires, *[**options])

        if public
          uri = URI.parse(signed_url)
          uri.query = nil
          uri.to_s
        else
          signed_url
        end
      end

      def clear!
        list.each(&:destroy)
      end

      protected

      def file(id)
        directory.files.new(key: path(id))
      end

      def get(id, &block)
        directory.files.get(path(id), &block)
      end

      def head(id)
        directory.files.head(path(id))
      end

      def provider
        connection.class
      end

      private

      def list
        directory.files.select { |file| file.key.start_with?(prefix.to_s) }
      end

      def path(id)
        [*prefix, id].join("/")
      end

      def put(io, id, shrine_metadata: {}, **upload_options)
        options = { content_type: shrine_metadata["mime_type"] }
        options.update(@upload_options)
        options.update(upload_options)

        directory.files.create(key: path(id), body: io, **options)
      end

      def copy(io, id, **upload_options)
        io.storage.head(io.id).copy(directory.key, path(id))
      end

      def copyable?(io)
        io.respond_to?(:storage) &&
        io.storage.is_a?(Storage::Fog) &&
        io.storage.provider == provider
      end
    end
  end
end
