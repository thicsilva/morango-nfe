class ApplicationController < ActionController::Base
   # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_user, :logged_in?
  def current_user
     @current_user ||= User.find(session[:user_id]) if session[:user_id]
          
  end
  
  def logged_in?
    !!current_user
  end
  
  def must_login
    if !logged_in?
      flash[:danger] = "Você ainda não esta logado, efetue o login."
      redirect_to login_path
    end
  end
  
  #USADO PARA NÃO DEIXAR DAR O ERRO DE RELACIONAMENTO ENTRE TABELAS
  #rescue_from 'ActiveRecord::InvalidForeignKey' do
  #redirect_to message_error_relation_tables_path
  #end
end
