class HeaderInputsController < ApplicationController
  before_action :set_header_input, only: [:show, :edit, :update, :destroy]
  before_action :show_supplier_name, only: [:new, :edit, :update, :create, :report_input, :index]
  before_action :must_login

  def report_input

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

      @supplier = Supplier.find_by(id: params[:supplier])

          #se não marcar nenhuma opção tras tudo com a data atual
          if params[:supplier].blank? && params[:tipo_consulta].blank? && params[:date1] && params[:date2]
            @item_inputs = ItemInput.joins(:header_input).where("header_inputs.status != ?", 'ABERTA').where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
            @total_items = ItemInput.joins(:header_input).where("header_inputs.status != ?", 'ABERTA').where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:total_value_cost)

          # se informar somente o fornecedor
          elsif params[:supplier] && params[:date1] && params[:date2] && params[:tipo_consulta].blank?
          @item_inputs = ItemInput.joins(:header_input).where("header_inputs.status != ?", 'ABERTA').where("header_inputs.supplier_id = ?", params[:supplier]).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
          @total_items = ItemInput.joins(:header_input).where("header_inputs.status != ?", 'ABERTA').where("header_inputs.supplier_id = ?", params[:supplier]).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:total_value_cost)

          # se for somente o tipo de consulta
          elsif params[:supplier].blank? && params[:date1] && params[:date2] && params[:tipo_consulta]
          @item_inputs = ItemInput.joins(:header_input).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("header_inputs.status = ?", params[:tipo_consulta]).order(:created_at)
          @total_items = ItemInput.joins(:header_input).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("header_inputs.status = ?", params[:tipo_consulta]).sum(:total_value_cost)

          #se tiver tudo informado
          elsif params[:supplier] && params[:date1] && params[:date2] && params[:tipo_consulta]
          @item_inputs = ItemInput.joins(:header_input).where("header_inputs.supplier_id = ?", params[:supplier]).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("header_inputs.status = ?", params[:tipo_consulta]).order(:created_at)
          @total_items = ItemInput.joins(:header_input).where("header_inputs.supplier_id = ?", params[:supplier]).where("item_inputs.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("header_inputs.status = ?", params[:tipo_consulta]).sum(:total_value_cost)

          end

     #render layout: false

  end


  def baixar

  @header_input = HeaderInput.find(params[:id])

  # se já está fechada não faz nada redireciona para a index
    if @header_input.status != 'ABERTA'
       redirect_to header_inputs_path and return
       end

    #verifica se foi adicionado algum item na entrada de compras
    @qnt_items = ItemInput.where(header_input_id: @header_input.id).count
      if @qnt_items == 0
        sweetalert_warning('Adicione pelo menos 1 item', 'aviso!', useRejections: false)
       redirect_to header_input_path(@header_input) and return
      end

    #verifica se foi informada a forma de pagamento
    #if header_input_params[:form_payment].blank?
    #  flash[:warning] = 'Selecione uma forma de pagamento válida!'
    #  redirect_to header_input_path(@header_input) and return
    #end


    # SE JÁ FOI RECEBIDA A O.S. não enviará para o contar á Receber
     if @header_input.status == 'PAGA'
           redirect_to header_input_path and return
     end

       if @header_input.status == 'ABERTA'
       @novostatus = 'Á PAGAR'
       end


       HeaderInput.update(@header_input.id, status: @novostatus, form_payment: "DINHEIRO")

       #FAZENDO A SOMA DE TODOS OS ITENS PARA JOGAR NO CONTAS Á RECEBER
       @total_items = ItemInput.where(header_input_id: @header_input.id).sum(:total_value_cost)

       #verifica se já foi enviado para o contas á pagar

       if Payment.exists?(header_input_id: @header_input.id)
         #renderiza a view para carregar o PDF dentro da pasta Layouts/reports
         @header_input = HeaderInput.find(params[:id])
         redirect_to header_inputs_path and return

         else


                #ENVIANDO PARA O CONTAS Á PAGAR
                 cta_pagar = Payment.new(params[:payment])
                 cta_pagar.doc_number = @header_input.id
                 cta_pagar.supplier_id = @header_input.supplier_id
                 cta_pagar.type_doc = "Compra"
                 cta_pagar.description = 'Referente a Entrada de compras ' + params[:id].to_s
                 cta_pagar.value_doc = @total_items
                 cta_pagar.due_date = Date.today
                 cta_pagar.installments = 1
                 cta_pagar.status = "Á PAGAR"
                 cta_pagar.header_input_id = @header_input.id
                 cta_pagar.categ_payment_id = 1
                 cta_pagar.form_payment = "DINHEIRO"
                 cta_pagar.save!

           end

        sweetalert_success('Dados salvos com sucesso.', 'Sucesso!', useRejections: false)
        redirect_to header_inputs_path

  end

  # GET /header_inputs
  # GET /header_inputs.json
  def index

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
      @supplier = Supplier.find_by(id: params[:supplier])
          #se não marcar nenhuma opção tras tudo com a data atual
          if params[:supplier].blank?
          @header_inputs = HeaderInput.where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
          # se informar somente o fornecedor
        else params[:supplier].present?
          @header_inputs = HeaderInput.where(supplier_id: params[:supplier]).where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
          end

  end

  # GET /header_inputs/1
  # GET /header_inputs/1.json
  def show

    @supplier = Supplier.find(@header_input.supplier_id)
    @total_items = ItemInput.where(header_input_id: @header_input.id).sum(:total_value_cost)
    @products = Product.order(:name)

  end

  # GET /header_inputs/new
  def new
    @header_input = HeaderInput.new
  end

  # GET /header_inputs/1/edit
  def edit
  end

  # POST /header_inputs
  # POST /header_inputs.json
  def create
    @header_input = HeaderInput.new(header_input_params)

    respond_to do |format|
      @header_input.status = 'ABERTA'
      if @header_input.save
        format.html { redirect_to @header_input, notice: 'Criado com sucesso.' }
        format.json { render :show, status: :created, location: @header_input }
      else
        format.html { render :new }
        format.json { render json: @header_input.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /header_inputs/1
  # PATCH/PUT /header_inputs/1.json
  def update
    respond_to do |format|
      if @header_input.update(header_input_params)
        format.html { redirect_to @header_input, notice: 'Entrada de compras atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @header_input }
        sweetalert_success('Dados atualizados com sucesso.', 'Sucesso!', useRejections: false)
      else
        format.html { render :edit }
        format.json { render json: @header_input.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /header_inputs/1
  # DELETE /header_inputs/1.json
  def destroy
    @header_input.destroy
    Payment.destroy_all(header_input_id: @header_input)
    respond_to do |format|
      format.html { redirect_to header_inputs_url, notice: 'Entrada de compras excluida com sucesso.' }
      sweetalert_success('Dados excluidos com sucesso.', 'Sucesso!', useRejections: false)
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_header_input
      @header_input = HeaderInput.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def header_input_params
      params.require(:header_input).permit(:supplier_id, :status, :form_payment)
    end

    def show_supplier_name
      @suppliers = Supplier.order(:name)
    end
end
