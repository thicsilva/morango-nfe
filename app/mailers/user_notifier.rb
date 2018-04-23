class UserNotifier < ApplicationMailer
  default :from => 'contato@ddti.com.br'

  # send a signup email to the user, pass in the user object that   contains the user's email address
  def send_signup_email(user)
    @user = user
    
    attachments.inline['logo.png'] = File.read( Rails.root.join("public/images/","logo.png") )
    
    mail( :to => @user.email,
    :subject => 'Dados para acesso ao Aplicativo' )
  end
end
