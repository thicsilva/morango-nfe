class CancelNumeralsController < ApplicationController
  before_action :set_cancel_numeral, only: [:show, :edit, :update, :destroy]
  before_action :show_emitente, only: [:new, :edit, :update, :index, :create]


  # GET /cancel_numerals
  # GET /cancel_numerals.json
  def index
    @cancel_numerals = CancelNumeral.all
  end

  # GET /cancel_numerals/1
  # GET /cancel_numerals/1.json
  def show
  end

  # GET /cancel_numerals/new
  def new
    @cancel_numeral = CancelNumeral.new
  end

  # GET /cancel_numerals/1/edit
  def edit
  end

   def create
    @cancel_numeral = CancelNumeral.new(cancel_numeral_params)

    if @cancel_numeral.serie.blank? || @cancel_numeral.inicial_number.blank? || @cancel_numeral.final_number.blank? || @cancel_numeral.justificativa.blank?
      alert_warning("Você precisa preencher todos os campos!", 'Atenção!', persistent: 'OK')
      redirect_to new_cancel_numeral_path
    end

    require 'net/http'
    require 'json'

    if @show_emitente.check_env = 'Teste'
        puts 'ambiente de TESTE'
        server = @show_emitente.url_server_test.to_s;
        token = @show_emitente.token_test.to_s;
       else
        puts 'ambiente de PRODUÇÃO'
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
       end
       # porta de comunicação
      port = @show_emitente.port.to_i

        #pegando os dados para enviar
        hash = {}
        hash[:cnpj] = cancel_numeral_params[:cnpj].to_s
        hash[:serie] = cancel_numeral_params[:serie].to_s
        hash[:justificativa] = cancel_numeral_params[:justificativa].to_s
        hash[:numero_inicial] = cancel_numeral_params[:inicial_number].to_s
        hash[:numero_final] = cancel_numeral_params[:final_number].to_s

        Net::HTTP.start(server, port) do |http|
        res = http.post("/v2/nfe/inutilizacao.json?&token=#{token}", hash.to_json)
        puts "Status = #{res.code}"
        puts "Body = #{res.body}"
        codigo_sefaz = res.code.to_i
        puts "A inutilização foi aceita para processamento!"
        #verifica agora se foi aceito o cancelamento
        if Net::HTTPSuccess === res
                  response = JSON.parse(res.body)
                  if response['status'].to_s == 'autorizado'
                      @cancel_numeral.url_xml = 'https://api.focusnfe.com.br' + response['caminho_xml'].to_s
                      if @cancel_numeral.save

                        sweetalert_success("Sucesso: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Sucesso!', useRejections: false)
                        redirect_to cancel_numerals_path and return
                      end
                    else
                      puts "Ocorreu um erro"
                      sweetalert_danger("Erro: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Erro!', useRejections: false)
                      redirect_to cancel_numerals_path and return
                  end
         else
           sweetalert_danger("Erro: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Erro!', useRejections: false)
                      redirect_to cancel_numerals_path and return
         end
    end
end

  # PATCH/PUT /cancel_numerals/1
  # PATCH/PUT /cancel_numerals/1.json
  def update
    respond_to do |format|
      if @cancel_numeral.update(cancel_numeral_params)
        format.html { redirect_to @cancel_numeral, notice: 'Cancel numeral was successfully updated.' }
        format.json { render :show, status: :ok, location: @cancel_numeral }
      else
        format.html { render :edit }
        format.json { render json: @cancel_numeral.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cancel_numerals/1
  # DELETE /cancel_numerals/1.json
  def destroy
    @cancel_numeral.destroy
    respond_to do |format|
      format.html { redirect_to cancel_numerals_url, notice: 'Cancel numeral was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cancel_numeral
      @cancel_numeral = CancelNumeral.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cancel_numeral_params
      params.require(:cancel_numeral).permit(:cnpj, :user, :serie, :inicial_number, :final_number, :justificativa, :url_xml)
    end

    def show_emitente
      @show_emitente = ExpireDate.first
    end
end
