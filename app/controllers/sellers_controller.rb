class SellersController < ApplicationController
  before_action :set_seller, only: [:show, :edit, :update, :destroy]
  #para trocar o id da cidade cadastrada na tabela pelo nome dela nas views show e index
  before_action :show_name_city, only: [:new, :edit, :update, :create, :index]
    #para trocar o id do estado cadastrado na tabela pelo nome dele nas views show e index
  before_action :show_name_state, only: [:new, :edit, :update, :create, :index]
  before_action :must_login

  #relatorio de vendedores
  def report_seller
    @sellers = Seller.all
    @total_sellers = Seller.count
    #render :layout => false
  end

  def index
    @sellers = Seller.all
  end

  # GET /sellers/1
  # GET /sellers/1.json
  def show
    
  end

  # GET /sellers/new
  def new
    @seller = Seller.new
  end

  # GET /sellers/1/edit
  def edit
  end

  # POST /sellers
  # POST /sellers.json
  def create
    @seller = Seller.new(seller_params)

    respond_to do |format|
      if @seller.save
        format.html { redirect_to @seller, notice: 'Vendedor criado com sucesso.' }
        format.json { render :show, status: :created, location: @seller }
      else
        format.html { render :new }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sellers/1
  # PATCH/PUT /sellers/1.json
  def update
    respond_to do |format|
      if @seller.update(seller_params)
        format.html { redirect_to @seller, notice: 'Vendedor atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @seller }
      else
        format.html { render :edit }
        format.json { render json: @seller.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sellers/1
  # DELETE /sellers/1.json
  def destroy
    @seller.destroy
    respond_to do |format|
      format.html { redirect_to sellers_url, notice: 'Vendedor excluido com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_seller
      @seller = Seller.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def seller_params
      params.require(:seller).permit(:name, :address, :neighborhood, :municipio, :uf, :zipcode, :phone, :celphone, :cpf, :email, :cidade_id, :estado_id)
    end
    
    def show_name_city
      @cidades = Cidade.order(:nome)
    end
    
    def show_name_state
      @estados = Estado.order(:sigla)
    end
end
