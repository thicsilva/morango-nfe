class ItemInputsController < ApplicationController
  before_action :set_item_input, only: [:show, :edit, :update, :destroy]
  before_action :must_login

   # GET /item_inputs/1/edit
  def edit
  end

  # POST /item_inputs
  # POST /item_inputs.json
  def create
    @header_input = HeaderInput.find(params[:header_input_id])


      if item_input_params[:cost_value].blank? || item_input_params[:qnt].blank?
     flash[:warning] = 'Informe todos os parametros exigidos!'
     redirect_to header_input_path(@header_input) and return
     else


      @item_input = @header_input.item_inputs.create(item_input_params)

      redirect_to header_input_path(@header_input)
     end

  end


  # DELETE /item_inputs/1
  # DELETE /item_inputs/1.json
  def destroy
    @header_input = HeaderInput.find(params[:header_input_id])
    @item_input = @header_input.item_inputs.find(params[:id])
    @item_input.destroy
    redirect_to header_input_path(@header_input)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item_input
      @item_input = ItemInput.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_input_params
      params.require(:item_input).permit(:product_id, :cost_value, :qnt, :total_value_cost, :header_input_id, :cest, :escala_relevante, :cnpj_fabricante, :codigo_beneficio_fiscal_uf)
    end
end
