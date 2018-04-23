class PaymentsController < ApplicationController
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  before_action :show_supplier_name, only: [:new, :edit, :update, :create, :index, :report_payment]
  before_action :show_categ_payment, only: [:new, :edit, :update, :create, :index]
  before_action :must_login
  
  #acerto por periodo e fornecedor
  def acerto_forn
   
   #é obrigátorio informar o fornecedor
    if params[:supplier].blank? || params[:date1].blank? || params[:date2].blank?
      flash[:warning] = 'Você precisa selecionar o Fornecedor, informar o periodo e consultar para poder efetivar a baixa em seguida!'
      redirect_to payments_path and return
    end
    
   #verifica se foi selecionado contas já PAGAS, se sim, não faz o acerto pra não mexer em baixas já feitas
    if params[:tipo_consulta] == 'PAGA' || params[:tipo_consulta].blank?
      flash[:warning] = 'Você não pode fazer acerto de fornecedor sem selecionar a opção CONTAS Á PAGAR, verifique os dados!'
      redirect_to payments_path and return
    end
    
    @check_payment = HeaderInput.where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').where('created_at::Date Between ? and ?', params[:date1],params[:date2]).count
    if @check_payment >= 1
    #atualizo para RECEBIDA todas as entradas com base no periodo informado
    HeaderInput.where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').where('created_at::Date Between ? and ?', params[:date1],params[:date2]).update_all(status: 'PAGA')  
    #atualizando todas as contas a receber do cliente informado e no periodo informado
    Payment.where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').where('created_at::Date Between ? and ?', params[:date1],params[:date2]).update_all(status: 'PAGA', payment_date: Date.today)  
        
     flash[:success] = 'Acerto realizado com sucesso!'
     redirect_to payments_path and return
     else
     flash[:warning] = 'Não existem dados para serem baixados!'
     redirect_to payments_path and return 
    end 
    
  end

  #relatorio
  def report_payment
    
      if params[:date1].blank?
        params[:date1] = Date.today
        @datainicial = Date.today
       else
        @datainicial = Date.strptime(params[:date1], '%Y-%m-%d').strftime("%d/%m/%Y")
      end

      if params[:date2].blank?
        params[:date2] = Date.today
      @datafinal = Date.today
      else
       @datafinal = Date.strptime(params[:date2], '%Y-%m-%d').strftime("%d/%m/%Y")
      end 
    
  #SE FOR RELATÓRIO GERAL
  if params[:type_report] == 'POR CATEGORIA DE DESPESA'
    
         if params[:tipo_consulta].blank?
           flash[:warning] = 'Você precisa informar se são Contas á Pagar ou Contas Pagas!'
           redirect_to report_payment_path and return
         end
    
          if params[:date1] && params[:date2] && params[:supplier].blank? && params[:tipo_consulta] == "Á PAGAR"
          @payments = Payment.select(:categ_payment_id, :status, "SUM(value_doc) as value_doc").where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á PAGAR').group(:categ_payment_id, :status).order(:categ_payment_id)
          @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á PAGAR').sum(:value_doc)
          
          elsif params[:date1] && params[:date2] && params[:supplier] && params[:tipo_consulta] == "Á PAGAR"
          @payments = Payment.select(:categ_payment_id, :status, "SUM(value_doc) as value_doc").where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').group(:categ_payment_id, :status).order(:categ_payment_id)
          @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').sum(:value_doc)   
   
          
          elsif params[:date1] && params[:date2] && params[:supplier].blank? && params[:tipo_consulta] == "PAGA"         
          @payments = Payment.select(:categ_payment_id, :status, "SUM(value_doc) as value_doc").where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'PAGA').group(:categ_payment_id, :status).order(:categ_payment_id)
          @total_payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'PAGA').sum(:value_doc)   
    
          elsif params[:date1] && params[:date2] && params[:supplier] && params[:tipo_consulta] == "PAGA"         
          @payments = Payment.select(:categ_payment_id, :status, "SUM(value_doc) as value_doc").where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'PAGA').group(:categ_payment_id, :status).order(:categ_payment_id)
          @total_payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'PAGA').sum(:value_doc)   

          end
  else
    
          @payments = Payment.includes(:supplier).where(due_date: Date.today).order(:due_date)
          @total_payments = Payment.limit(10).sum(:value_doc)
          
          if params[:date1] && params[:date2] && params[:supplier].blank? && params[:tipo_consulta] == "Á PAGAR"
             @payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á PAGAR').order(:due_date)
             @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á PAGAR').sum(:value_doc)   
          
          elsif params[:date1] && params[:date2] && params[:supplier] && params[:tipo_consulta] == "Á PAGAR"
             @payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').order(:due_date)
             @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'Á PAGAR').sum(:value_doc)   

                
          elsif params[:date1] && params[:date2] && params[:supplier].blank? && params[:tipo_consulta] == "PAGA"
             @payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'PAGA').order(:due_date)
             @total_payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'PAGA').sum(:value_doc)   
          
          elsif params[:date1] && params[:date2] && params[:supplier] && params[:tipo_consulta] == "PAGA"
             @payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'PAGA').order(:due_date)
             @total_payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(supplier_id: params[:supplier]).where(status: 'PAGA').sum(:value_doc)   

          
          elsif params[:date1] && params[:date2] && params[:supplier].blank? && params[:tipo_consulta].blank?
             @payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:due_date)
             @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:value_doc)   
      
          end
    end 
      #render layout: false
  end

  # GET /payments
  # GET /payments.json
  def index

  if params[:date1].blank?
  params[:date1] = Date.today
  end
  
    if params[:date2].blank?
  params[:date2] = Date.today
  end

    if params[:supplier].present?
      #guardando os dados da consulta pra utilizar na baixa
      @tipo_consulta_acerto = params[:tipo_consulta]
      @fornecedor_acerto = params[:supplier]
      @data1_acerto = params[:date1]
      @data2_acerto = params[:date2]
    end
    
    if params[:supplier].blank? && params[:date1].blank? && params[:date2].blank? && params[:tipo_consulta].blank?
    @payments = Payment.includes(:supplier).where(due_date: Date.today).order(:due_date)
    @total_payments = Payment.where(due_date: Date.today).sum(:value_doc)
    
    elsif params[:supplier].blank? && params[:date1].blank? && params[:date2].blank? && params[:tipo_consulta].present?
       @payments = Payment.where(status: params[:tipo_consulta]).order(:due_date)
       @total_payments = Payment.where(status: params[:tipo_consulta]).sum(:value_doc)   
    
    elsif params[:supplier].blank? && params[:date1].present? && params[:date2].present? && params[:tipo_consulta].blank?
       @payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:due_date)
       @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:value_doc)   
    
    elsif params[:supplier].blank? && params[:date1].present? && params[:date2].present? && params[:tipo_consulta].present?
       @payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: params[:tipo_consulta]).order(:due_date)
       @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: params[:tipo_consulta]).sum(:value_doc)   

    elsif params[:supplier].present? && params[:date1].present? && params[:date2].present? && params[:tipo_consulta].present?
       @payments = Payment.where(supplier_id: params[:supplier]).where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: params[:tipo_consulta]).order(:due_date)
       @total_payments = Payment.where(supplier_id: params[:supplier]).where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: params[:tipo_consulta]).sum(:value_doc)   
            
    elsif params[:supplier].present? && params[:date1].present? && params[:date2].present? && params[:tipo_consulta].blank?
       @payments = Payment.where(supplier_id: params[:supplier]).where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:due_date)
       @total_payments = Payment.where(supplier_id: params[:supplier]).where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:value_doc)   
        
    end
        
  end

  # GET /payments/1
  # GET /payments/1.json
  def show
     #mostra o nome ao inves do id
    @supplier = Supplier.find(@payment.supplier_id)
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  # POST /payments.json
  def create
    
    #se não informou a data do vencimento
    if payment_params[:due_date].blank?
    flash[:warning] = 'Informe a data do vencimento!'
      redirect_to new_payment_path and return
    end
    
    #se não informou a data do pagamento
    if payment_params[:payment_date].blank?
    flash[:warning] = 'Informe a data do pagamento!'
    redirect_to new_payment_path and return
    end
    
    
    @payment = Payment.new(payment_params)
    @qnt_parcela = payment_params[:installments].to_i
    
    #inserindo os valores fixos conforme solicitado pelo cliente
    #@payment.supplier_id = '9'
    @payment.type_doc = "OUTROS"
    @payment.form_payment = "DINHEIRO"
      
    #se for somente uma parcela ele só salva uma vez
    if @qnt_parcela == 1
    
            respond_to do |format|
              if @payment.save
                format.html { redirect_to @payment, notice: 'Pagamento cadastrado com sucesso.' }
                format.json { render :show, status: :created, location: @payment }
              else
                format.html { render :new }
                format.json { render json: @payment.errors, status: :unprocessable_entity }
              end
            end
     else
          #se tiver mais de uma parcela ele lança a quantidade de vezes no sistema
          if @qnt_parcela > 1
            @valor_total = payment_params[:value_doc].to_f
            @resultado = @valor_total / @qnt_parcela
            @resultado = (@resultado).round(2)
            @data_vencto = payment_params[:due_date]
          end
    
        while @qnt_parcela > 0
         @conta_parc = @conta_parc.to_i + 1 
         @data_vencto = @data_vencto.to_date + 1.month 
         @payment.description = payment_params[:description] + ' Parc. ' + @conta_parc.to_s
         @payment.due_date = @data_vencto
         @payment.payment_date = Date.today
         @payment.value_doc = @resultado
                   
            if @payment.save
              #só vai fazer o redirect quando finalizar
            else
              format.html { render :new }
              format.json { render json: @payment.errors, status: :unprocessable_entity }
            end
         @qnt_parcela = @qnt_parcela - 1
         @payment = Payment.new(payment_params)   
        end 
      redirect_to payments_path
      flash[:success] = 'Parcelamento realizado com sucesso!'
     end  
          
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    
    #se não informou a data do vencimento
    if payment_params[:due_date].blank?
    flash[:warning] = 'Informe a data do vencimento!'
      redirect_to edit_payment_path(@payment) and return
    end
    
    #se não informou a data do pagamento
    if payment_params[:payment_date].blank?
    flash[:warning] = 'Informe a data do pagamento!'
      redirect_to edit_payment_path(@payment) and return
    end
    
    
    #verifica se foi informada a forma de pagamento na baixa
    if payment_params[:payment_date].present? && payment_params[:form_payment].blank?
      flash[:warning] = 'Selecione uma forma de Pagamento!'
      redirect_to edit_payment_path(@payment) and return
    end
    
    #se informou a data da baixa e não alterou para PAGA o status
    if payment_params[:payment_date].present? && payment_params[:status] == 'Á PAGAR'
    flash[:warning] = 'Altere o Status para PAGA, já que você informou a data de pagamento!'
      redirect_to edit_payment_path(@payment) and return
    end
    
    #se alterou para PAGA o status e não informou a data do pagamento
    if payment_params[:status] == 'PAGA' && payment_params[:payment_date].blank?
    flash[:warning] = 'Informe a data de pagamento, já que você alerou o status para PAGA!'
      redirect_to edit_payment_path(@payment) and return
    end
    
    #verifica se essa conta é referente á uma compra
    @header_input = HeaderInput.find_by(id: @payment.header_input_id)
    if @header_input.present? && @header_input.status = 'Á PAGAR'
      HeaderInput.update(@header_input.id, status: 'PAGA')
    end
     
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to @payment, notice: 'Pagamento atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Pagamento excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:doc_number, :description, :due_date, :payment_date, :installments, :value_doc, :supplier_id, :type_doc, :status, :form_payment, :categ_payment_id)
    end
    
    #mostra o nome do fornecedor
    def show_supplier_name
      @suppliers = Supplier.order(:name)
    end
    
    #mostra a categ_payment
    def show_categ_payment
      @categ_payments = CategPayment.order(:name)
    end
end
