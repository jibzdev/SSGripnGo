require 'fileutils'

module Admin
  class GalleryController < BaseController
    GALLERY_DIR = Rails.root.join('public', 'assets', 'show')

    layout false, only: [:index]

    def index
      @images = gallery_files.map { |path| to_public_path(path) }
    end

    def create
      file = params[:image]
      unless file.respond_to?(:original_filename)
        redirect_to admin_gallery_index_path, alert: 'Please choose an image to upload.' and return
      end

      ensure_directory!
      filename = "#{SecureRandom.hex(10)}#{File.extname(file.original_filename)}"
      destination = GALLERY_DIR.join(filename)

      File.open(destination, 'wb') { |f| f.write(file.read) }

      redirect_to admin_gallery_index_path, notice: 'Image uploaded successfully.'
    rescue StandardError => e
      Rails.logger.error("Gallery upload failed: #{e.message}")
      redirect_to admin_gallery_index_path, alert: 'Unable to upload image.'
    end

    def destroy
      relative = params[:path].to_s.sub(%r{\A/}, '')
      file_path = Rails.root.join('public', relative)

      if within_gallery?(file_path) && File.exist?(file_path)
        File.delete(file_path)
        redirect_to admin_gallery_index_path, notice: 'Image removed.'
      else
        redirect_to admin_gallery_index_path, alert: 'Image not found.'
      end
    end

    private

    def gallery_files
      return [] unless Dir.exist?(GALLERY_DIR)
      Dir.glob(GALLERY_DIR.join('**', '*')).select { |path| File.file?(path) }
    end

    def to_public_path(path)
      path.sub(Rails.root.join('public').to_s, '').tr('\\', '/')
    end

    def ensure_directory!
      FileUtils.mkdir_p(GALLERY_DIR)
    end

    def within_gallery?(path)
      path.to_s.start_with?(GALLERY_DIR.to_s)
    end
  end
end

