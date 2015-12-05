require "down"

class Shrine
  module Storage
    class Fog
      attr_reader :connection, :directory, :prefix

      def initialize(directory:, prefix: nil, public: true, connection: nil, **options)
        @connection = connection || ::Fog::Storage.new(options)
        @directory = @connection.directories.new(key: directory)
        @prefix = prefix
        @public = public
      end

      def upload(io, id, metadata = {})
        if copyable?(io)
          copy(io, id, metadata)
        else
          put(io, id, metadata)
        end
      end

      def download(id)
        Down.download(url(id))
      end

      def open(id)
        download(id)
      end

      def read(id)
        get(id).body
      end

      def exists?(id)
        !!head(id)
      end

      def delete(id)
        head(id).destroy
      end

      def url(id, **options)
        head(id).public_url
      end

      def clear!(confirm = nil)
        raise Shrine::Confirm unless confirm == :confirm
        list.each(&:destroy)
      end

      protected

      def get(id)
        directory.files.get(path(id))
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

      def put(io, id, metadata = {})
        options = {key: path(id), body: io, public: @public}
        options[:content_type] = metadata["mime_type"]

        directory.files.create(options)
        io.rewind
      end

      def copy(io, id, metadata = {})
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
