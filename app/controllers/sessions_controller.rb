class SessionsController < ApplicationController

  def expired_date
    #just to show expired view
  end

  def new
  end

  def create

    user = User.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
    session[:user_id] = user.id

    if current_user.type_access != 'MASTER'
      #verifica se a licença de uso está ok somente se o usuario não for MASTER
      check_date = ExpireDate.first
      if check_date.active == true && check_date.date_expire <= Date.today
      flash[:danger] = 'A sua licença expirou, por favor entre em contato com o suporte para adquirir uma nova licença.'
      session[:user_id] = nil
      redirect_to contact_path and return
      end
     end
    #se estiver tudo ok e a licença ok
    #se estiver tudo ok e a licença ok
    sweetalert("Oi" + " " +  user.name + "!", 'Bem vindo!', imageUrl: 'images/logo.png', useRejections: false)
    redirect_to root_path

    else
      sweetalert_error('Email ou Senha incorretos, por favor verifique os dados.', 'Atenção!', useRejections: false)

      redirect_to root_path
      #render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    sweetalert_success('See you soon!', '', useRejections: false)
    redirect_to root_path
  end

end
