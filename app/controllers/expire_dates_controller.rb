class ExpireDatesController < ApplicationController
  before_action :set_expire_date, only: [:show, :edit, :update, :destroy]

  # GET /expire_dates
  # GET /expire_dates.json
  def index
    @expire_dates = ExpireDate.all
  end

  # GET /expire_dates/1
  # GET /expire_dates/1.json
  def show
  end

  # GET /expire_dates/new
  def new
    @expire_date = ExpireDate.new
  end

  # GET /expire_dates/1/edit
  def edit
  end

  # POST /expire_dates
  # POST /expire_dates.json
  def create

    @expire_date = ExpireDate.new(expire_date_params)

    respond_to do |format|
      if @expire_date.save
        format.html { redirect_to @expire_date, notice: 'Data de Expiração Criada.' }
        format.json { render :show, status: :created, location: @expire_date }
        sweetalert_success('Data de Expiração Criada.', 'Sucesso!', useRejections: false)
      else
        format.html { render :new }
        format.json { render json: @expire_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /expire_dates/1
  # PATCH/PUT /expire_dates/1.json
  def update
    respond_to do |format|
      if @expire_date.update(expire_date_params)
        format.html { redirect_to @expire_date, notice: 'Data de Expiração atualizada.' }
        format.json { render :show, status: :ok, location: @expire_date }
        sweetalert_success('Data de Expiração atualizada.', 'Sucesso!', useRejections: false)
      else
        format.html { render :edit }
        format.json { render json: @expire_date.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /expire_dates/1
  # DELETE /expire_dates/1.json
  def destroy
    @expire_date.destroy
    respond_to do |format|
      format.html { redirect_to expire_dates_url, notice: 'Data Excluida.' }
      sweetalert_success('Data de Expiração excluida.', 'Sucesso!', useRejections: false)
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_expire_date
      @expire_date = ExpireDate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def expire_date_params
      params.require(:expire_date).permit(:date_expire, :active,:razao,:nome_fantasia,:cnpj,:cep,:endereco,:numero,:bairro,:cidade,:uf,:telefone,:inscricao,:check_date,:expiration_date,:check_env,:url_server_test,:token_test,:url_server_production,:token_production,:port,:sleep, :updated_cost)
    end
end
