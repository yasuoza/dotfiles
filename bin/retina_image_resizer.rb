#!env ruby
require 'rubygems'
require 'RMagick'

images_dir = ARGV[0]

if images_dir == nil
  puts "Error! Input images directory"
  exit
end

if !FileTest.exist?(images_dir)
  puts "Error! There is no such directory #{images_dir}"
  exit
end

PSD_WIDTH = 640
PSD_HEIGHT = 960
WIDTH_RATIO = 320.quo(PSD_WIDTH)
HEIGHT_RATIO = 480.quo(PSD_HEIGHT)


def file_resizer(arg_dir)
  Dir.entries(arg_dir).each do |filename|
    # Do recursively
    if FileTest.directory?(arg_dir + "/" + filename)
      next if /\.+/ =~ filename
      file_resizer(arg_dir + "/" + filename)
    end

    img_type = File.extname(filename).downcase
    if (img_type == '.png' || img_type == '.jpg' || img_type == '.tif')
      ext = File.extname(filename)
      basename = File.basename(filename, ext)
      dir = File.dirname(filename)

      if /(.+)@2x(#{ext})$/ =~ filename
        exportdir = "#{dir}/resized_#{arg_dir}"
        exportname = exportdir + "/" + $1 + $2

        folderFlag = true
        if !FileTest.exist?(exportdir)
          Dir.mkdir(exportdir)
        else
          if FileTest.file?(exportdir)
            puts "Error! There is already #{exportname} in #{exportdir}"
            folderFlag = false
          end
        end

        if folderFlag
          original = Magick::Image.read(arg_dir + "/" + filename).first
          width = original.columns
          height = original.rows

          #Resize
          image = original.resize(width * WIDTH_RATIO, height * HEIGHT_RATIO,
                                  filter=Magick::LanczosFilter, 0.9)
          image.write(exportname)
        end
      end
    end
  end
end

file_resizer(images_dir)

puts "Converted images"
