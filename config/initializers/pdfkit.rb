PDFKit.configure do |config|

  if ["development"].include?(Rails.env)
   #RODANDO O PDF LOCALMENTE
  config.wkhtmltopdf = 'bin/wkhtmltopdf/wkhtmltopdf.exe'
    
  else
    #if your site is hosted on heroku or any other hosting server which is 64bit
   #RODANDO O PDF NO HEROKU
  config.wkhtmltopdf = 'bin/wkhtmltopdf/wkhtmltopdf-linux-amd64'
  end

  config.default_options = {
    :encoding=>"UTF-8",
    :page_size=>"A4",
    :margin_top=>"0.25in",
    :margin_right=>"0.1in",
    :margin_bottom=>"0.25in",
    :margin_left=>"0.1in",
    :disable_smart_shrinking=> false
  }
end