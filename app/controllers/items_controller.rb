class ItemsController < ApplicationController
  #before_action :set_item, only: [:show, :edit, :update, :destroy]
  before_action :must_login

  #chama o modal para a edição do item
  def editar_item
    @item = Item.find_by(id: params[:id_do_item])
    @produto = Product.find_by(id: @item.product_id)

      respond_to do |format|
      format.html
      format.js
    end
  end


   #form modal para editar tributos
    def editar_tributo
    @item = Item.find_by(id: params[:id])
    @products = Product.order(:name)
    @produto = Product.find_by(id: @item.product_id)
    @cfops = Cfop.order(:codigo)
    if @item.cest.present?
      @check_cest = 'sim'
    else
      @check_cest = 'não'
    end
    respond_to do |format|
    format.html
    format.js
    end

  end

  def create
   @invoice = Invoice.find(params[:invoice_id])

    #verifica se já existe o mesmo item adicionado na venda
    check_item = Item.where(invoice_id: @invoice.id, product_id: item_params[:product_id])
    if check_item.present?
      flash[:warning] = 'Este produto já foi adicionado!'
      redirect_to invoice_path(@invoice) and return
    end

      if item_params[:qnt].blank?
     flash[:warning] = 'Informe uma quantidade para o produto!'
     redirect_to invoice_path(@invoice) and return
     else
      @item = @invoice.items.create(item_params)
      total_geral_venda = Item.where(invoice_id: @item.invoice_id).sum(:total_value_sale)
      Invoice.update(@item.invoice_id, valor_total: total_geral_venda)
      redirect_to invoice_path(@invoice)
     end
  end

  def edit
  end

   def update

     #quando é editado o item
     if item_params[:id_do_item] == 'SIM'
     @item = Item.find(params[:id])
     Item.where('id = ?', @item.id).update_all(qnt: item_params[:qnt], sale_value: item_params[:sale_value], total_value_sale: item_params[:total_value_sale])
     total_geral_venda = Item.where(invoice_id: @item.invoice_id).sum(:total_value_sale)
     Invoice.update(@item.invoice_id, valor_total: total_geral_venda)
     @invoice = Invoice.find(@item.invoice_id)
     redirect_to invoice_path(@invoice) and return
     end

    #quando é marcado para aplicar os impostos de uma só vez em todos os itens da venda
    if item_params[:apply_all] == '1'
        @item = Item.find(params[:id])
      Item.where('invoice_id = ?', @item.invoice_id).update_all(cfop: item_params[:cfop], icms_situacao_tributaria: item_params[:icms_situacao_tributaria], pis_situacao_tributaria: item_params[:pis_situacao_tributaria], cofins_situacao_tributaria: item_params[:cofins_situacao_tributaria])
      @invoice = Invoice.find(@item.invoice_id)
      redirect_to invoice_path(@invoice) and return
    end

    @item = Item.find(params[:id])
    if @item.update(item_params)
      @invoice = Invoice.find(@item.invoice_id)
      @item = @invoice.items.find(params[:id])

     redirect_to invoice_path(@invoice)
    end


  end

  def destroy
    @invoice = Invoice.find(params[:invoice_id])
    @item = @invoice.items.find(params[:id])
    @item.destroy

    total_geral_venda = Item.where(invoice_id: @item.invoice_id).sum(:total_value_sale)
    Invoice.update(@item.invoice_id, valor_total: total_geral_venda)

    redirect_to invoice_path(@invoice)
  end


private

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:qnt, :cost_value, :sale_value, :total_value_cost, :total_value_sale, :product_id, :invoice_id, :codigo_ncm, :profit_sale, :cfop, :icms_origem, :ipi_situacao_tributaria,:icms_situacao_tributaria,:pis_situacao_tributaria,:cofins_situacao_tributaria, :apply_all,:valor_frete, :valor_seguro, :lucro_liquido, :cest, :escala_relevante, :cnpj_fabricante, :codigo_beneficio_fiscal_uf, :fcp_percentual_uf_destino, :fcp_valor_uf_destino, :fcp_base_calculo_uf_destino, :id_do_item)
    end


end
