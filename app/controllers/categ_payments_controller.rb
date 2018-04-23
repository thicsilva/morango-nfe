class CategPaymentsController < ApplicationController
  before_action :set_categ_payment, only: [:show, :edit, :update, :destroy]

  #relatório de categoria de despesas
  def report_categ
    @categ_payments = CategPayment.all
    @total_categ = CategPayment.count
    #render :layout => false
  end

  def index
    @categ_payments = CategPayment.order(:name)
  end

  # GET /categ_payments/1
  # GET /categ_payments/1.json
  def show
  end

  # GET /categ_payments/new
  def new
    @categ_payment = CategPayment.new
  end

  # GET /categ_payments/1/edit
  def edit
  end

  # POST /categ_payments
  # POST /categ_payments.json
  def create
    @categ_payment = CategPayment.new(categ_payment_params)

    respond_to do |format|
      if @categ_payment.save
        format.html { redirect_to @categ_payment, notice: 'Categoria criada com sucesso.' }
        format.json { render :show, status: :created, location: @categ_payment }
      else
        format.html { render :new }
        format.json { render json: @categ_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /categ_payments/1
  # PATCH/PUT /categ_payments/1.json
  def update
    respond_to do |format|
      if @categ_payment.update(categ_payment_params)
        format.html { redirect_to @categ_payment, notice: 'Categoria atualizada com sucesso.' }
        format.json { render :show, status: :ok, location: @categ_payment }
      else
        format.html { render :edit }
        format.json { render json: @categ_payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /categ_payments/1
  # DELETE /categ_payments/1.json
  def destroy
    @categ_payment.destroy
    respond_to do |format|
      format.html { redirect_to categ_payments_url, notice: 'Categoria excluida com sucesso.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_categ_payment
      @categ_payment = CategPayment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def categ_payment_params
      params.require(:categ_payment).permit(:name)
    end
end
