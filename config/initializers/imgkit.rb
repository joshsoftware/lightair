IMGKit.configure do |config|
  config.wkhtmltoimage = File.expand_path('../../../bin/wkhtmltoimage',__FILE__).to_s
  config.default_format = :png
  # config.default_options = {:quality => 60 }
end

