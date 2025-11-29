require 'fileutils'

module Admin
  class MediaController < BaseController
    MEDIA_DIR = Rails.root.join('public', 'images ', 'products')

    skip_before_action :verify_authenticity_token, only: [:create], if: -> { request.format.json? }

    def index
      files = media_files

      respond_to do |format|
        format.html do
          @media_files = files
        end
        format.json do
          render json: files.map { |path| serialize_file(path) }
        end
      end
    end

    def create
      file = params[:image]
      unless file.respond_to?(:original_filename)
        render json: { error: 'No file attached' }, status: :unprocessable_entity and return
      end

      ensure_directory!

      filename = "#{SecureRandom.hex(10)}#{File.extname(file.original_filename)}"
      destination = MEDIA_DIR.join(filename)

      File.open(destination, 'wb') { |f| f.write(file.read) }

      render json: serialize_file(destination), status: :created
    rescue StandardError => e
      Rails.logger.error("Media upload failed: #{e.message}")
      render json: { error: 'Upload failed' }, status: :internal_server_error
    end

    def destroy
      file = media_files.find { |path| File.basename(path) == params[:id].to_s }
      if file && File.exist?(file)
        File.delete(file)
        respond_to do |format|
          format.html { redirect_to admin_media_index_path, notice: 'Media deleted.' }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html { redirect_to admin_media_index_path, alert: 'Media not found.' }
          format.json { render json: { error: 'Not found' }, status: :not_found }
        end
      end
    end

    private

    def media_files
      return [] unless Dir.exist?(MEDIA_DIR)
      Dir.glob(MEDIA_DIR.join('*')).select { |path| File.file?(path) }.sort_by { |path| File.mtime(path) }.reverse
    end

    def serialize_file(path)
      {
        url: to_public_url(path),
        filename: File.basename(path),
        size: File.size(path)
      }
    end

    def to_public_url(path)
      path.sub(Rails.root.join('public').to_s, '').tr('\\', '/')
    end

    def ensure_directory!
      FileUtils.mkdir_p(MEDIA_DIR)
    end
  end
end

