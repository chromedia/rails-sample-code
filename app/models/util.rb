module Util
  require 'fileutils'

  def save_file(file, id='', old_name = '', directory='')
    dir_path = 'public/uploads'
    dir_path = dir_path +'/' + directory if directory.present?

    if file.present?
      filename = id.present? ? id +File.extname(file.original_filename) : file.original_filename
      img_path = dir_path +'/' +filename
      versioned_img_path = img_path +'?' + SecureRandom.hex(3)

      FileUtils::mkdir_p dir_path unless File.directory? dir_path #Create uploads directory in public if it doesn't exists
      File.open(img_path, 'wb') { |f| f.write(file.read) } #Save file to uploads directory

      return versioned_img_path.gsub 'public', ''
    else
      FileUtils.rm('public' + old_name.split('?')[0]) if old_name.present?
      return ''
    end
  end

  def delete_file(file_path)
    return if file_path.blank?

    fullpath = 'public' + file_path.split('?')[0]
    FileUtils.rm(fullpath) if File.exist?(fullpath)
  end
end