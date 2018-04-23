class ShippingsController < ApplicationController
  before_action :set_shipping, only: [:show, :edit, :update, :destroy]
  before_action :must_login

  # GET /shippings
  # GET /shippings.json
  def index
    @total_shippings = Shipping.count
    
    if params[:descricao].present?
    #@invoices = Invoice.where("destinatario.nome_destinatario like ?", "%#{params[:name_client]}%")
    @shippings = Shipping.where("name ILIKE ?", "%#{params[:descricao]}%").order(:name)
    else
    @shippings = Shipping.all  
    end
 
  end

  # GET /shippings/1
  # GET /shippings/1.json
  def show
  end

  # GET /shippings/new
  def new
    @shipping = Shipping.new
  end

  # GET /shippings/1/edit
  def edit
  end

  # POST /shippings
  # POST /shippings.json
  def create
    @shipping = Shipping.new(shipping_params)
    
    #se não aguardar carregar os dados
    if @shipping.state == '...'
      flash[:warning] = 'Você precisa informar o CEP e aguardar os dados do endereço serem preenchidos.'
        redirect_to new_shipping_path and return
    end

    respond_to do |format|
      if @shipping.save
        
        format.html { }
        format.json { render :show, status: :created, location: @shipping }
        flash[:success] = 'Transportadora criada com sucesso.'
        redirect_to @shipping
      else
        format.html { render :new }
        format.json { render json: @shipping.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shippings/1
  # PATCH/PUT /shippings/1.json
  def update
    
   #se não aguardar carregar os dados
    if shipping_params[:state] == '...'
        flash[:warning] = 'Você precisa informar o CEP e aguardar os dados do endereço serem preenchidos.'
        redirect_to edit_shipping_path(@shipping) and return
    end
    
    respond_to do |format|
      if @shipping.update(shipping_params)
        
        format.html { }
        format.json { render :show, status: :ok, location: @shipping }
        flash[:success] = 'Transportadora alterada com sucesso.'
        redirect_to @shipping
      else
        format.html { render :edit }
        format.json { render json: @shipping.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shippings/1
  # DELETE /shippings/1.json
  def destroy
    @shipping.destroy
   
    respond_to do |format|
      format.html { }
      format.json { head :no_content }
      redirect_to shippings_url
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_shipping
      @shipping = Shipping.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def shipping_params
      params.require(:shipping).permit(:name, :cep, :address, :neighborhood, :city, :state, :phone, :cnpj, :inscricao, :cpf)
    end
end
