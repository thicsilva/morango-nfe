require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dsoft
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    
    config.time_zone = "Brasilia"
    config.active_record.default_timezone = :local

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.default_locale = "pt-BR"
    I18n.enforce_available_locales = false
    
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    #pdf
    # options will be passed to PDFKit.new
    config.middleware.use PDFKit::Middleware, :print_media_type => true #, :orientation => 'Landscape'
    
    #configurando para executar em modo de produção
    config.assets.enabled = true
    
    #configurando o css para o pdf local
    #config.assets.paths << "#{Rails.root}/app/assets/stylesheets"
 
    #CONFIGURANDO O EMAIL
  config.action_mailer.smtp_settings = {
  address: "smtp.gmail.com",
  port: 587,
  domain: "gmail.com",
  user_name: "ddsuportservice@gmail.com",
  password: "pearljam10",
  authentication: :plain,
  enable_starttls_auto: true
}
  config.action_mailer.default_url_options = {
  host: "gmail.com"
}
  end
end
