class MessagesController < ApplicationController
  
  def message_error_relation_tables
    #chama a mensagem informando que não pode excluir um cadastro com relacionamento em outra tabela
    end
  
  def new
    @message = Message.new
  end

  def create
    @message = Message.new(message_params)
    
    if @message.valid?
      MessageMailer.new_message(@message).deliver_now
      redirect_to root_path
      flash[:success] = "Sua mensagem foi enviada com sucesso, em breve retornaremos."
    else
      flash[:alert] = "Ocorreu um erro ao tentar enviar sua mensagem, tente novamente."
      render :new
    end
  end

private

  def message_params
    params.require(:message).permit(:name, :email, :content)
  end
  
end
