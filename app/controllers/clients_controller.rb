class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy, :download]
  #para trocar o id da cidade cadastrada na tabela pelo nome dela nas views show e index
  before_action :show_name_city, only: [:new, :edit, :update, :create, :index]
    #para trocar o id do estado cadastrado na tabela pelo nome dele nas views show e index
  before_action :show_name_state, only: [:new, :edit, :update, :create, :index]
  before_action :show_seller_name, only: [:new, :edit, :update, :create, :index]
  before_action :show_route_name, only: [:new, :edit, :update, :create, :index]
  before_action :must_login



  # relatorio de clientes
  def report_client
    @clients = Client.order(:name)
    @total_clients = Client.count
    #pra poder carregar o css somente que está no proprio relatório
    #render :layout => false

  end

  def index
   @clients = Client.includes(:cidade, :estado, :seller).order(:name)

    @total_clients = Client.count

        if params[:search] && params[:tipo_consulta] == "1"
          @clients = Client.where("name like ?", "%#{params[:search]}%")

          #aqui é para gerar o resultado da query em pdf na tela
          #html = render_to_string(:action => '../clients/index', :layout => false)
          #pdf = PDFKit.new(html)
          #send_data(pdf.to_pdf, :filename => 'report.pdf', :type => 'application/pdf', :disposition => 'inline')

            elsif params[:search] && params[:tipo_consulta] == "2"
                @clients = Client.where("cnpj like ?", "%#{params[:search]}%")

            elsif params[:search] && params[:tipo_consulta] == "3"
          @clients = Client.where("email like ?", "%#{params[:search]}%")
        end

  end

  # GET /clients/1
  # GET /clients/1.json
  def show

  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  # POST /clients
  # POST /clients.json
  def create

   @client = Client.new(client_params)

    #se não aguardar carregar os dados
    if @client.state == '...'
        sweetalert_warning('Você precisa informar o CEP e aguardar os dados do endereço serem preenchidos.', 'Aviso!', useRejections: false)
        redirect_to new_client_path and return
    end

    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Cliente criado com sucesso.' }
        format.json { render :show, status: :created, location: @client }
        sweetalert_success('Cliente cadastrado com sucesso.', 'Sucesso!', useRejections: false)
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update

   #se não aguardar carregar os dados
    if client_params[:state] == '...'
        sweetalert_warning('Você precisa informar o CEP e aguardar os dados do endereço serem preenchidos.', 'Aviso!', useRejections: false)
        redirect_to edit_client_path(@client) and return
    end

    respond_to do |format|

      if @client.update(client_params)
        format.html { redirect_to @client, notice: 'Cliente atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @client }
        sweetalert_success('Cliente atualizado com sucesso.', 'Sucesso!', useRejections: false)
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Cliente foi excluido.' }
      format.json { head :no_content }
      sweetalert_success('Cliente excluido com sucesso.', 'Sucesso!', useRejections: false)
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:name, :address, :neighborhood, :zipcode, :phone, :cnpj, :cellphone, :email, :state, :city, :contact_name, :seller_id,:cpf,:numero,:complemento,:cod_municipio,:indicador_inscr,:inscr_est,:inscr_suframa,:inscr_municipal,:codigo_pais,:pais, :route_id, :position)
    end
    # pra mostrar o nome da cidade
    def show_name_city
      @cidades = Cidade.order(:nome)
    end
    #pra mostrar o nome do estado
    def show_name_state
      @estados = Estado.order(:sigla)
    end
    #mostra o vendedor na invoice
    def show_seller_name
      @sellers = Seller.order(:name)
    end

    def show_route_name
      @routes = Route.order(:name)
    end

end
