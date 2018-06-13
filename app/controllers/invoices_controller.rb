class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy, :nfe]
  before_action :show_client_name, only: [:new, :edit, :update, :create, :index, :report_invoice, :report_nfe]
  before_action :show_routes, only: [:new, :edit, :update, :create, :index, :report_invoice, :report_nfe, :rpt_compras, :report_invoice]
  before_action :must_login

  #faz a baixa em massa das prevendas selecionadas
  #faz a baixa em massa de todos os lançamentos marcados
    def change_multiple_prevenda
            if params[:item_ids].present?
                      #só para jogar no log e saber quais foram as contas baixadas
                      id_das_contas = params[:item_ids].to_s

                      #verifica se algum dos lançamentos marcados já é uma venda, se tiver não realiza a baixa em massa
                      check_status = Invoice.where(id: params[:item_ids]).where(type_invoice: 'Venda')
                        if check_status.present?
                          sweetalert_warning('Selecione somente Pré vendas!', 'Atenção!', persistent: 'OK')
                          redirect_back(fallback_location: root_path) and return
                        end

                        #verifica primeiro se já foi feito o calculo do custo médio dos produtos
                        check_update_cost = ExpireDate.where(updated_cost: Date.today)
                          if check_update_cost.blank?
                            puts 'FEZ O PRIMEIRO CALCULO DE CUSTO DO DIA'
                            ExpireDate.update_all(updated_cost: Date.today)
                            ultima_data = ItemInput.maximum('created_at::date')
                            items_input = ItemInput.select('DISTINCT product_id').where("created_at::date = ?", ultima_data)
                                items_input.each do |item_input|
                                      #somando a quantidade de todos os produtos que foram comprados
                                      qnt_total_comprado = ItemInput.where('created_at::date = ?', ultima_data).where(product_id: item_input.product_id.to_i).sum(:qnt)
                                      #somando os totais gastos com cada compra também
                                      valor_total_comprado = ItemInput.where('created_at::date = ?', ultima_data).where(product_id: item_input.product_id.to_i).sum(:total_value_cost)
                                      #fazendo o calculo do custo médio do produto
                                      custo_medio_prod = valor_total_comprado.to_f / qnt_total_comprado.to_i
                                      custo_medio_prod = custo_medio_prod.round(2)
                                      Product.update(item_input.product_id.to_i, cost_value: custo_medio_prod, data_atualizacao_custo: Date.today)
                                      #inserindo o valor de custo de cada produto nas pré vendas
                                      ultima_data_item = Invoice.maximum(:data_prevenda)
                                      Item.joins(:invoice).where(product_id: item_input.product_id.to_i).where("invoices.data_prevenda = ?", ultima_data_item).update_all(cost_value: custo_medio_prod)
                                end
                                  #calcula o total geral de custo e profit de cada pré venda que esta sendo convertida e atualiza
                                  items = Item.where(invoice_id: params[:item_ids])
                                      items.each do |item|
                                        total_geral_custo = item.qnt.to_i * item.cost_value.to_f
                                        total_profit = item.total_value_sale.to_f - total_geral_custo.to_f
                                        Item.update(item.id, total_value_cost: total_geral_custo, profit_sale: total_profit)
                                      end
                          else
                            puts 'JÁ TEM O CUSTO CALCULADO DO DIA'
                                  items = Item.where(invoice_id: params[:item_ids])
                                      items.each do |item|
                                        total_geral_custo = item.qnt.to_i * item.cost_value.to_f
                                        total_profit = item.total_value_sale.to_f - total_geral_custo.to_f
                                        Item.update(item.id, total_value_cost: total_geral_custo, profit_sale: total_profit)
                                      end
                          end

                          #Atualiza o status e valores de cada pré venda envolvida na baixa em massa
                          params[:item_ids].each {|x| print '',
                            #pega os dados da invoice para fazer a inserção no contas a receber e converter em venda

                            #FAZENDO A SOMA DE TODOS OS ITENS PARA JOGAR NO CONTAS Á RECEBER
                            @total_items_cost = Item.where(invoice_id: x.to_i).sum(:total_value_cost)
                            @total_items_profit = Item.where(invoice_id: x.to_i).sum(:profit_sale)
                            @total_items = Item.where(invoice_id: x.to_i).sum(:total_value_sale)

                            Invoice.update(x.to_i, type_invoice: 'Venda', status: 'RECEBIDA', form_receipt: 'DINHEIRO', installments: 1, valor_total: @total_items)
                            @invoice = Invoice.find(x.to_i)

                                 #ENVIANDO PARA O CONTAS Á RECEBER
                                 cta_receber = Receipt.new(params[:receipt])
                                 cta_receber.doc_number = @invoice.id
                                 cta_receber.client_id = @invoice.client_id
                                 cta_receber.type_doc = "O.S"
                                 cta_receber.discription = 'Referente a Venda: ' + @invoice.id.to_s
                                 #total vendas
                                 cta_receber.value_doc = @total_items
                                 #total custo
                                 cta_receber.t_cost = @total_items_cost
                                 #total_lucro
                                 cta_receber.t_profit = @total_items_profit
                                 cta_receber.due_date = @invoice.data_prevenda
                                 cta_receber.installments = 1
                                 #Verifica se foi marcado para fazer a baixa automática
                                 cta_receber.status = "RECEBIDA"
                                 cta_receber.receipt_date = @invoice.data_prevenda
                                 cta_receber.invoice_id = @invoice.id
                                 cta_receber.form_receipt = 'DINHEIRO'
                                 cta_receber.save!

                          }

                      sweetalert_success('Vendas convertidas com sucesso!', 'Sucesso!', useRejections: false)
                      redirect_back(fallback_location: root_path)
            else
                      sweetalert_warning('Você precisa selecionar pelo menos uma pré venda!', 'Atenção!', persistent: 'Ok')
                      redirect_back(fallback_location: root_path)
            end
      end

  #relaório do que precisa ser comprado separado por rota e produto
  def rpt_compras

    @data_pedidos = Invoice.maximum('data_prevenda')
    @data_compras = ItemInput.maximum('created_at::date')

        @compras_por_rota = Item.joins(:routes).joins(:product).select('products.name as produto, SUM(DISTINCT qnt) as qnt').group('products.name')
        @pre_vendas_do_dia = Item.joins('inner join invoices on items.invoice_id = invoices.id').joins(:product).select('products.name as produto, SUM(qnt) as quantidade, products.cost_value as custo_medio_unitario, SUM(DISTINCT total_value_cost) as total_custo').where('invoices.data_prevenda::Date = ?', @data_pedidos).group('products.name, products.cost_value')
        @compras_do_dia = ItemInput.joins('inner join header_inputs on item_inputs.header_input_id = header_inputs.id').joins(:product).select('products.name as produto, SUM(qnt) as quantidade, products.cost_value as custo_medio_unitario, SUM(DISTINCT total_value_cost) as total_custo').where('item_inputs.created_at::Date >= ?', @data_pedidos).group('products.name, products.cost_value')
        @total_geral = Item.joins(:invoice).where('invoices.data_prevenda::Date = ?', @data_pedidos).sum(:total_value_cost)
    #se não informar a rota
    if params[:nome_da_rota].blank?
      @compras = Invoice.joins(:routes).joins(:items).joins(:client).joins("INNER JOIN products ON products.id = items.product_id").select('clients.route_id as id_rota, routes.name as rota, sum(items.qnt) as quantidade').where('invoices.data_prevenda::Date = ?', @data_pedidos).group('routes.name').group('id_rota')
        sql = "select routes.name as rota, clients.name as cliente, clients.position as posicao, products.name as produto, qnt as quantidade, items.sale_value as valor_venda from items
         inner join products on items.product_id = products.id
         inner join invoices on items.invoice_id = invoices.id
         inner join clients on invoices.client_id = clients.id
         inner join routes on clients.route_id = routes.id
         where invoices.data_prevenda::date = to_date('#{@data_pedidos}', 'DD/MM/YYYY') order by rota, posicao"
    #se informar a rota na consulta
   else
     @rota_selecionada = params[:nome_da_rota]
     @compras = Invoice.joins(:routes).joins(:items).joins(:client).joins("INNER JOIN products ON products.id = items.product_id").select('clients.route_id as id_rota, routes.name as rota, sum(items.qnt) as quantidade').where('routes.name = ?', params[:nome_da_rota]).where('invoices.data_prevenda::Date = ?', @data_pedidos).group('routes.name').group('id_rota')
          sql = "select routes.id, routes.name as rota, clients.name as cliente, clients.position as posicao, products.name as produto, qnt as quantidade, items.sale_value as valor_venda from items
          inner join products on items.product_id = products.id
          inner join invoices on items.invoice_id = invoices.id
          inner join clients on invoices.client_id = clients.id
          inner join routes on clients.route_id = routes.id
          where routes.name = '#{params[:nome_da_rota].to_s}' and invoices.data_prevenda::date = to_date('#{@data_pedidos}', 'DD/MM/YYYY') order by rota, posicao"
   end
    @list = ActiveRecord::Base.connection.execute(sql)
    # this will hold the crosstab
    @clients = {}
    # this will hold the unique products for the header
    @uniqProducts = {}
    # Creating crosstab structure
    @list.each do |row|
      routeName   = row['rota']
      clientName  = row['cliente']
      productName = row['produto']
      saleValue = row['valor_venda']
      @uniqProducts[ productName ] = true;
      # cria um hash vazio se aquela chave ainda nao existe
      @clients[ clientName ] = {} if @clients[ clientName ].nil?
      @clients[ clientName ][ productName ] = row['quantidade'].to_s + ' | ' + 'R$' + sprintf("%.2f", row['valor_venda']).to_s
    end
  end

  def converter_venda
    @invoice = Invoice.find(params[:id])

  #verifica se ja houve atualização do valor de custo dos produtos
  check_update_cost = ExpireDate.where(updated_cost: Date.today)
    if check_update_cost.blank?
      puts 'FEZ O PRIMEIRO CALCULO'
      ExpireDate.update_all(updated_cost: Date.today)
      ultima_data = ItemInput.maximum('created_at::date')
      items_input = ItemInput.select('DISTINCT product_id').where("created_at::date = ?", ultima_data)
          items_input.each do |item_input|
                #somando a quantidade de todos os produtos que foram comprados
                qnt_total_comprado = ItemInput.where('created_at::date = ?', ultima_data).where(product_id: item_input.product_id.to_i).sum(:qnt)
                #somando os totais gastos com cada compra também
                valor_total_comprado = ItemInput.where('created_at::date = ?', ultima_data).where(product_id: item_input.product_id.to_i).sum(:total_value_cost)
                #fazendo o calculo do custo médio do produto
                custo_medio_prod = valor_total_comprado.to_f / qnt_total_comprado.to_i
                custo_medio_prod = custo_medio_prod.round(2)

                Product.update(item_input.product_id.to_i, cost_value: custo_medio_prod, data_atualizacao_custo: Date.today)
                #inserindo o valor de custo de cada produto nas pré vendas
                ultima_data_item = Invoice.maximum(:data_prevenda)
                Item.joins(:invoice).where(product_id: item_input.product_id.to_i).where("invoices.data_prevenda = ?", ultima_data_item).update_all(cost_value: custo_medio_prod)
          end
            #calcula o total geral de custo e profit desta venda que esta sendo convertida e atualiza
            items = Item.where(invoice_id: params[:id])
                items.each do |item|
                  total_geral_custo = item.qnt.to_i * item.cost_value.to_f
                  total_profit = item.total_value_sale.to_f - total_geral_custo.to_f
                  Item.update(item.id, total_value_cost: total_geral_custo, profit_sale: total_profit)
                end
            #sweetalert_success('Venda convertida com sucesso.', 'Sucesso!', useRejections: false)
    else
      puts 'JÁ TEM O CUSTO CALCULADO'
            items = Item.where(invoice_id: params[:id])
                items.each do |item|
                  total_geral_custo = item.qnt.to_i * item.cost_value.to_f
                  total_profit = item.total_value_sale.to_f - total_geral_custo.to_f
                  Item.update(item.id, total_value_cost: total_geral_custo, profit_sale: total_profit)
                end
            #sweetalert_success('Venda convertida com sucesso.', 'Sucesso!', useRejections: false)
    end


    #FAZENDO A SOMA DE TODOS OS ITENS PARA JOGAR NO CONTAS Á RECEBER
    @total_items_cost = Item.where(invoice_id: @invoice.id).sum(:total_value_cost)
    @total_items_profit = Item.where(invoice_id: @invoice.id).sum(:profit_sale)
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)

    Invoice.update(@invoice.id, type_invoice: 'Venda', status: 'RECEBIDA', form_receipt: 'DINHEIRO', installments: 1, valor_total: @total_items)

         #ENVIANDO PARA O CONTAS Á RECEBER
         cta_receber = Receipt.new(params[:receipt])
         cta_receber.doc_number = @invoice.id
         cta_receber.client_id = @invoice.client_id
         cta_receber.type_doc = "O.S"
         cta_receber.discription = 'Referente a Venda: ' + params[:id].to_s
         #total vendas
         cta_receber.value_doc = @total_items
         #total custo
         cta_receber.t_cost = @total_items_cost
         #total_lucro
         cta_receber.t_profit = @total_items_profit
         cta_receber.due_date = @invoice.data_prevenda
         cta_receber.installments = 1
         #Verifica se foi marcado para fazer a baixa automática
         cta_receber.status = "RECEBIDA"
         cta_receber.receipt_date = @invoice.data_prevenda
         cta_receber.invoice_id = @invoice.id
         cta_receber.form_receipt = 'DINHEIRO'
         cta_receber.save!


    sweetalert_success('Venda convertida com sucesso!', 'Sucesso!', useRejections: false)
    redirect_back(fallback_location: root_path)
  end

  #relatório de notas fiscais emitidas
  def report_nfe

    #inseri essa linha abaixo para o tipo de consulta sempre ser venda, naõ tem mais orçamentos
    params[:tipo_consulta] = 'Venda'

    if params[:tipo_consulta].blank?
      params[:tipo_consulta] = 'Orçamento'
    end

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

      @client = Client.find_by(id: params[:client_id])

          if params[:tipo_consulta] == "Orçamento" && params[:client_id].blank? && params[:date1] && params[:date2]
             @invoices = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
             @total_items = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:total_value_sale)
             @qnt_items = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).count



          elsif params[:tipo_consulta] == "Orçamento" && params[:client_id] && params[:date1] && params[:date2]
             @invoices = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).order(:created_at)
             @total_items = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).sum(:total_value_sale)
             @qnt_items = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).count


          elsif params[:tipo_consulta] == "Venda" && params[:client_id].blank? && params[:date1] && params[:date2]
             @invoices = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at)
             @total_items = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:total_value_sale)
             @qnt_items = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).count



          elsif params[:tipo_consulta] == "Venda" && params[:client_id] && params[:date1] && params[:date2]
             @invoices = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at).where("client_id = ?", params[:client_id]).order(:created_at)
             @total_items = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).sum(:total_value_sale)
             @qnt_items = Invoice.where(type_invoice: params[:tipo_consulta]).where("status LIKE ?", "%NFE emitida%").where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).count

          end

  end

  #chama a tela para correção da NFCe
  def corrige_nfe
    @invoice = Invoice.find(params[:id])
    @show_emitente = ExpireDate.first
  end

  #envia os dados da carta de correção
  def correcao_nfe

    #para verificar em qual ambiente está a App
    @show_emitente = ExpireDate.first

      if @show_emitente.check_env = 'Teste'
        puts 'ambiente de TESTE'
        server = @show_emitente.url_server_test.to_s;
        token = @show_emitente.token_test.to_s;
        valor_ssl = false
      else
        puts 'ambiente de PRODUÇÃO'
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
        valor_ssl = true
      end
       # porta de comunicação
      port = @show_emitente.port.to_i

      ref = invoice_params[:id].to_i
      hash = {}
      hash[:correcao] = invoice_params[:just_correcao].to_s

      Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
      res = http.post("/v2/nfe/carta_correcao.json?ref=#{ref}&token=#{token}", hash.to_json)

        puts "Status = #{res.code}"
        puts "Body = #{res.body}"
        codigo_sefaz = res.code.to_i
        response = JSON.parse(res.body)
      # Se a nota for aceita para processamento, o body vem vazio, deve-se agendar
      # em seguida uma consulta da nota
      puts "Nota aceita para processamento"

      #Atualiza o status da NF informando que foi cancelada
      if Net::HTTPSuccess === res

        if response["status_sefaz"].to_i == 135
              #salvando a url da danfe e xml na venda e alterando o status
              @invoice = Invoice.find(invoice_params[:id])
              if response['status'] == 'processando_autorizacao'

                sweetalert_warning("Não conseguimos formalizar a sua carta de correção porque o SEFAZ está demorando mais do que o normal, tente novamente mais tarde: " + "(" + "#{res2.code}" + ")" + " #{res2.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)
              elsif response['status'] == 'autorizado'
                Invoice.update(@invoice.id, status: @invoice.status + ' + correção', just_correcao: invoice_params[:just_correcao], caminho_pdf_correcao: 'https://api.focusnfe.com.br' + response['caminho_pdf_carta_correcao'], caminho_xml_correcao: 'https://api.focusnfe.com.br' + response['caminho_xml_carta_correcao'])
                sweetalert_success("Carta de correção enviada com sucesso! " + "(" + "#{res.code}" + ")".force_encoding("UTF-8"), 'Aviso!', useRejections: false)

              end

           end

        #CASO ACONTEÇA ALGUM ERRO NO CANCELAMENTO DA NFE
        else
          puts "O CODIGO SEFAZ É: " + codigo_sefaz.to_s
          # ocorreu um erro
          puts "Ocorreu um erro"
          # para interpretar a resposta, use uma das linhas abaixo
          sweetalert_warning("Erro: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)
          redirect_to invoices_path and return
          end
       end

  end


  #chama a tela de cancelamento NFCe
  def cancelar_nfe
    @invoice = Invoice.find(params[:id])
    @show_emitente = ExpireDate.first
  end

  #efetiva o cancelamento da NFCe
  def cancel_nfe

    require 'net/http'
    require 'json'

    #para verificar em qual ambiente está a App
    @show_emitente = ExpireDate.first

      if @show_emitente.check_env = 'Teste'
        puts 'ambiente de TESTE'
        server = @show_emitente.url_server_test.to_s;
        token = @show_emitente.token_test.to_s;
        valor_ssl = false
      else
        puts 'ambiente de PRODUÇÃO'
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
        valor_ssl = true
      end
       # porta de comunicação
      port = @show_emitente.port.to_i

      ref = invoice_params[:id].to_i
      hash = {}
      hash[:justificativa] = invoice_params[:justificativa_cancelamento].to_s

      Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
        request = Net::HTTP::Delete.new "/v2/nfe/#{ref}.json"
        request.basic_auth token, ''
        response = http.request request, hash.to_json

        code = response.code
        resposta = JSON.parse(response.body)
        # todos os códigos de resposta que começam com 2 são sucesso
        if code.start_with? '2'
          puts 'ESSE É O INSPECT ' + resposta.inspect
          @invoice = Invoice.find(invoice_params[:id])
                Invoice.update(@invoice.id, status: 'NFE cancelada', justificativa_cancelamento: invoice_params[:justificativa_cancelamento], caminho_xml_cancelamento: 'https://api.focusnfe.com.br' + resposta['caminho_xml_cancelamento'])

                    sweetalert_success("Código: #{resposta['status_sefaz']}, Mensagem: #{resposta['mensagem_sefaz']}", 'Mensagem!', useRejections: false)
                      #inserindo no log de atividades
                      log = Loginfo.new(params[:loginfo])
                      log.employee = current_user.name
                      log.task = 'Cancelou Nota fiscal ref venda: ' + invoice_params[:id].to_s
                      log.save!
                      redirect_to invoices_path and return
        else
              # SE A NOTA JÁ FOI CANCELADA
              if resposta['codigo'].to_s == 'already_processed'

                Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
                  request = Net::HTTP::Get.new "/v2/nfe/#{ref}.json"
                  request.basic_auth token, ''
                  response = http.request request, hash.to_json
                  code = response.code
                  resposta = JSON.parse(response.body)

                  # todos os códigos de resposta que começam com 2 são sucesso
                  if code.start_with? '2'
                    @invoice = Invoice.find(invoice_params[:id])
                          Invoice.update(@invoice.id, status: 'NFE cancelada', justificativa_cancelamento: invoice_params[:justificativa_cancelamento], url_xml: 'https://api.focusnfe.com.br' + 			resposta['caminho_xml_nota_fiscal'], caminho_xml_cancelamento: 'https://api.focusnfe.com.br' + resposta['caminho_xml_cancelamento'])
                          sweetalert_success("Esta nota fiscal já foi cancelada!", 'Aviso', useRejections: false)
                    ref = params[:id].to_i

                    redirect_to invoices_path(:id => ref) and return
                  else
                    sweetalert_success("Status SEFAZ: Código: #{code}, Mensagem: #{resposta['caminho_xml_cancelamento']}", 'Aviso', useRejections: false)

                    ref = params[:id].to_i

                    # apenas para visualizar a resposta
                    puts 'AQUI É O QUE VEM ' +  resposta.inspect
                    redirect_to invoices_path(:id => ref) and return
                  end
              end

          end

 # QUALQUER OUTRO ERRO
          puts "Erro: Código #{resposta['codigo']}, Mensagem de erro: #{resposta['mensagem']}"
                sweetalert_success("Erro: Código #{resposta['codigo']}, Mensagem de erro: #{resposta['mensagem']}", 'Sucesso!', useRejections: false)
             redirect_to invoices_path and return
        end
      end
end


  #consultar NFCe
  def consulta_nfe
  end

  #verifica qual é o status da NFCe emitida pelo cód de referencia
  def check_status

    if params[:id].blank?

      sweetalert_warning('Informe um código de referencia válido!', 'Aviso!', useRejections: false)
      redirect_to consulta_nfe_path and return
    end

    require 'net/http'
    require 'json'

        #para verificar em qual ambiente está a App
        @show_emitente = ExpireDate.first

       if @show_emitente.check_env = 'Teste'
        puts 'ambiente de TESTE'
        server = @show_emitente.url_server_test.to_s;
        token = @show_emitente.token_test.to_s;
        valor_ssl = false
       else
        puts 'ambiente de PRODUÇÃO'
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
        valor_ssl = true
       end
       # porta de comunicação
      port = @show_emitente.port.to_i

        puts  "=> Teste de consulta"
        # O processo de envio de NFSe é assíncrono, e pode ser necessário
        # aguardar até que a nota seja processada

        # tem que ser a mesma ref usada no envio
        ref = params[:id].to_i

        #em produção tem que ser true o ssl
        Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
          request = Net::HTTP::Get.new "/v2/nfe/#{ref}.json"
          request.basic_auth token, ''
          response = http.request request, hash.to_json
          code = response.code
          resposta = JSON.parse(response.body)
          # todos os códigos de resposta que começam com 2 são sucesso
          if code.start_with? '2'
            sweetalert_success("Status SEFAZ: Código: #{code}, Mensagem: #{resposta['mensagem_sefaz']}", 'Sucesso!', useRejections: false)
            ref = params[:id].to_i

            # apenas para visualizar a resposta
            puts resposta.inspect
            redirect_to consulta_nfe_path(:id => ref) and return
          else

            sweetalert_success("Status SEFAZ: Código: #{code}, Mensagem: #{resposta['mensagem_sefaz']}", 'Sucesso!', useRejections: false)
            ref = params[:id].to_i

            # apenas para visualizar a resposta
            puts resposta.inspect
            redirect_to consulta_nfe_path(:id => ref) and return
          end
        end

end

  #gerar a NFE
  def nfe
   @invoice.update(invoice_params)

    #verifica se os campos obrigatórios foram preenchidos primeiro
    if invoice_params[:finalidade_emissao].blank?
      sweetalert_warning('Informe a finalidade!', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
    elsif invoice_params[:natureza_operacao].blank?
      sweetalert_warning('Informe a natureza da operação!', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:tipo_documento].blank?
      sweetalert_warning('Informe o tipo de documento!', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:data_emissao].blank?
      sweetalert_warning('Informe a data de emissão', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:forma_pagamento_nf].blank?
      sweetalert_warning('Informe a forma de pagamento!', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:modalidade_frete].blank?
      sweetalert_warning('Informe a modalidade de frete!', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      #elsif invoice_params[:modalidade_frete] != '9' && invoice_params[:shipping_id].blank?
      #sweetalert_warning('Selecione a transportadora que irá fazer o frete!', 'Aviso!', useRejections: false)
      #redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:modalidade_frete] != '9' && invoice_params[:veiculo_placa].blank?
      sweetalert_warning('É obrigatória a informação da placa do veiculo e transportadora', 'Aviso!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return
      elsif invoice_params[:modalidade_frete] != '9' && invoice_params[:veiculo_uf].blank?
      sweetalert_warning('É obrigatória a informação do Estado (UF) do Veiculo da transportadora!', useRejections: false)
      redirect_to gerar_nfe_invoice_path(invoice_params) and return

    end

  #para verificar em qual ambiente está a App
    @show_emitente = ExpireDate.first

      if @show_emitente.check_env == 'Teste'
        server = @show_emitente.url_server_test.to_s;
        token = @show_emitente.token_test.to_s;
        valor_ssl = false
      else
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
        valor_ssl = true
      end

       # porta de comunicação
      port = @show_emitente.port.to_i

     @invoices = Invoice.find(params[:id])
     @emitente = ExpireDate.first


     #VERIFICA SE FOI INFORMADO FRETE OU SEGURO PARA FAZER OS CALCULOS ABAIXO
     if invoice_params[:valor_frete].present? || invoice_params[:valor_seguro].present?
     qnt_itens = Item.where(invoice_id: params[:id]).count
     end

     #vai compor o total_frete
     if invoice_params[:valor_frete].present?
     frete_itens = invoice_params[:valor_frete].to_f / qnt_itens.to_i
     frete_itens = frete_itens.round(2)
     else
       frete_itens = 0
       invoice_params[:valor_frete] == 0
     end

     #vai compor o seguro
     if invoice_params[:valor_seguro].present?
       puts 'passou aqui hein!!'
     seguro_itens = invoice_params[:valor_seguro].to_f / qnt_itens.to_i
     seguro_itens = seguro_itens.round(2)
     else
       seguro_itens = 0
       invoice_params[:valor_seguro] == 0
     end

     #atualizando o valor do frete e seguro rateado em cada item na venda
     Item.where(invoice_id: params[:id]).update_all(valor_frete: frete_itens, valor_seguro: seguro_itens)

      #carregando os dados do cabeçalho da NF
      hash = {}
      #dados do cabeçalho da invoice
      hash[:natureza_operacao] = @invoices.natureza_operacao
      hash[:forma_pagamento] = @invoices.forma_pagamento_nf
      hash[:data_emissao] = @invoices.data_emissao
      hash[:data_entrada_saida] = @invoices.data_emissao
      hash[:tipo_documento] = @invoices.tipo_documento
      hash[:finalidade_emissao] = @invoices.finalidade_emissao
      hash[:informacoes_adicionais_contribuinte] = @invoices.informacoes_adicionais_contribuinte

      hash[:cnpj_emitente] = @emitente.cnpj
      hash[:nome_emitente] = @emitente.razao
      hash[:nome_fantasia_emitente] = @emitente.nome_fantasia
      hash[:logradouro_emitente] = @emitente.endereco
      hash[:numero_emitente] = @emitente.numero
      hash[:bairro_emitente] = @emitente.bairro
      hash[:municipio_emitente] = @emitente.cidade
      hash[:uf_emitente] = @emitente.uf
      hash[:cep_emitente] = @emitente.cep
      hash[:inscricao_estadual_emitente] = @emitente.inscricao

      #dados do destinatário
      if @show_emitente.check_env == 'Teste'
      hash[:nome_destinatario] = 'NF-E EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL'
      else
      hash[:nome_destinatario] = @invoices.client.name
      end

      if @invoices.client.cpf.present?
      hash[:cpf_destinatario] = @invoices.client.cpf
      else
      hash[:cnpj_destinatario] = @invoices.client.cnpj
      end
      hash[:inscricao_estadual_destinatario] = @invoices.client.inscr_est
      hash[:telefone_client] = @invoices.client.phone
      hash[:logradouro_destinatario] = @invoices.client.address
      hash[:numero_destinatario] = @invoices.client.numero
      hash[:bairro_destinatario] = @invoices.client.neighborhood
      hash[:municipio_destinatario] = @invoices.client.city
      hash[:uf_destinatario] = @invoices.client.state
      hash[:pais_destinatario] = 'Brasil'
      hash[:cep_destinatario] = @invoices.client.zipcode
      hash[:email_destinatario] = @invoices.client.email
      #calculos das aliquotas vem aqui, não foi feito ainda!
      hash[:icms_base_calculo] = 0
      hash[:icms_valor_total] = 0
      hash[:icms_base_calculo_st] = 0
      hash[:icms_valor_total_st] = 0
      hash[:valor_ipi] = 0

      #NOVO CAMPO FORMAS DE pagamento
      hash[:formas_pagamento] = []
      @invoices.items.each do |f|
      f_hash = {}
      f_hash[:forma_pagamento] = @invoices.forma_pagamento_nf
      f_hash[:troco] = @invoices.valor_troco
      hash[:formas_pagamento] << f_hash
     end

      #verifica se foi informada a modalidade de frete, se for sem frete ele pula este bloco
     if @invoices.modalidade_frete == 'Sem frete'
       #não passa os parametros porque é sem frete, para evitar o problema de preencher os dados e marcar sem frete depois
     else

      #valores de frete, seguro produtos e total geral
      hash[:modalidade_frete] = @invoices.modalidade_frete
      hash[:valor_frete] = @invoices.valor_frete
      hash[:valor_seguro] = @invoices.valor_seguro
      hash[:valor_produtos] = @invoices.valor_produtos
      hash[:valor_total] = @invoices.valor_total
      #dados da transportadora
      #verifica se houve frete, se sim carrega os dados da transportadora
      if @invoices.modalidade_frete != 9 && @invoices.shipping_id.present?
        if @invoices.shipping.cpf.present?
        hash[:cpf_transportador] = @invoices.shipping.cpf
        else
        hash[:cnpj_transportador] = @invoices.shipping.cnpj
        end
      hash[:nome_transportador] = @invoices.shipping.name
      hash[:inscricao_estadual_transportador] = @invoices.shipping.inscricao
      hash[:endereco_transportador] = @invoices.shipping.address
      hash[:municipio_transportador] = @invoices.shipping.city
      hash[:uf_transportador] = @invoices.shipping.state
      #dados do veiculo
      hash[:veiculo_placa] = @invoices.veiculo_placa
      hash[:veiculo_uf] = @invoices.veiculo_uf
      hash[:veiculo_rntc] = @invoices.veiculo_rntc
      #dados sobre a carga transportada
      hash[:volumes] = []
        @invoices.items.each do |v|
        v_hash = {}
        v_hash[:quantidade] = @invoices.quantidade_volume
        v_hash[:especie] = @invoices.especie
        v_hash[:marca] = @invoices.marca
        v_hash[:numero] = @invoices.numero
        v_hash[:peso_bruto] = @invoices.peso_bruto
        v_hash[:peso_liquido] = @invoices.peso_liquido

        hash[:volumes] << v_hash
       end
     end
      #inserindo no log de atividades
        #log = Loginfo.new(params[:loginfo])
        #log.employee = current_user.name
        #log.task = 'Emitiu Nota fiscal ref venda: ' + @invoices.id.to_s
        #log.save!
      end


      #carregando os itens da NF
      hash[:items] = []
      counter = 0
      @invoices.items.order(:created_at).each do |i|
      i_hash = {}
      i_hash[:numero_item] = counter+=1
      i_hash[:codigo_produto] = i.product_id
      i_hash[:descricao] = i.product.name
      i_hash[:cfop] = i.cfop
      i_hash[:unidade_comercial] = i.product.unidade_comercial
      i_hash[:quantidade_comercial] = i.qnt
      i_hash[:valor_unitario_comercial] = i.sale_value
      i_hash[:valor_unitario_tributavel] = i.sale_value
      i_hash[:unidade_tributavel] = i.product.unidade_comercial
      i_hash[:codigo_ncm] = i.codigo_ncm
      i_hash[:quantidade_tributavel] = i.qnt
      i_hash[:valor_frete] = i.valor_frete
      i_hash[:valor_seguro] = i.valor_seguro
      i_hash[:valor_bruto] = i.total_value_sale
      i_hash[:icms_situacao_tributaria] = i.icms_situacao_tributaria
      i_hash[:icms_origem] = 0
      i_hash[:pis_situacao_tributaria] = i.pis_situacao_tributaria
      i_hash[:cofins_situacao_tributaria] = i.cofins_situacao_tributaria
      #NOVOS CAMPOS PARA O CEST
       i_hash[:cest] = i.cest
       if i.cest.present?
       i_hash[:escala_relevante] = i.escala_relevante
       i_hash[:cnpj_fabricante] = i.cnpj_fabricante
       i_hash[:codigo_beneficio_fiscal_uf] = i.codigo_beneficio_fiscal_uf
     end
      hash[:items] << i_hash
      end

      puts "=> Teste de envio"

          # A referência é uma string que identifica univocamente uma NFSe e
          # será usada para consultas posteriores
          # tem que ser a mesma ref usada no envio
          ref = params[:id].to_i
      require 'net/http'
      Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
        res = http.post("/v2/nfe.json?ref=#{ref}&token=#{token}", hash.to_json)
        puts "Status = #{res.code}"
        puts "Body = #{res.body}"
        codigo_sefaz = res.code.to_i
        response = JSON.parse(res.body)
        #verifica se houve problema de validação em algum campo da nota fiscal
        if response['codigo'].to_s == 'erro_validacao_schema'
          sweetalert_warning(response['mensagem'].force_encoding("UTF-8"), 'Aviso!', useRejections: false)
          redirect_to invoice_path(@invoice) and return
        end

    if Net::HTTPSuccess === res
      # Se a nota for aceita para processamento, o body vem vazio, deve-se agendar
      # em seguida uma consulta da nota
      puts "Nota aceita para processamento"

      #aguarda alguns segundos já pra fazer a consulta da correção e pegar as url's do pdf e xml do cancelamento
          sleep @show_emitente.sleep.to_i
          url = "/v2/nfe/consultar.json?ref=#{ref}&token=#{token}"
           res2 = http.get(url)
            response = JSON.parse(res2.body)

          puts "CODIGO DO SEFAZ RES2 É = #{res2.code}"
          puts "Body do RES2 = #{res2.body}"
          codigo_sefaz = res2.code.to_i

              if codigo_sefaz == 200
                response = JSON.parse(res2.body)
                sweetalert_warning(response['mensagem_sefaz'].to_s, 'Aviso!', useRejections: false)
                  #gerando a URL da DANFE
                  if response['status'] == 'autorizado'
                    @invoice = Invoice.find(params[:id])
                      Invoice.update(@invoice.id, status: 'NFE emitida Nº' + response['numero'], url_danfe: 'https://api.focusnfe.com.br' + response['caminho_danfe'], url_xml: 'https://api.focusnfe.com.br' + response['caminho_xml_nota_fiscal'])
                      #if @show_emitente.check_env == 'Produção'
                        #atualizando o ultimo numero da nota fiscal emitida
                      #  numero_ultima_nf = @ultima_nf_emitida.numero + 1
                      #  ConfigNf.update(@ultima_nf_emitida.id, numero: numero_ultima_nf)
                      #end
                      sweetalert_success('Nota fiscal Nº' + response['numero'].to_s + ' foi emitida com sucesso!', 'Sucesso!', useRejections: false)
                      #GLÓRIA Á DEUS, DESTA FORMA O NFE É CARREGADA DENTRO DA APP!!!
                        #redireciona para o cupom fiscal
                        @invoice.update(invoice_params)
                        redirect_to invoices_path and return
                  elsif response['status'] == 'processando_autorizacao'

                     sweetalert_warning("Não houve tempo hábil para processar sua requisição, tente novamente: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)
                      redirect_to invoice_path(@invoice) and return
                  end
              end

    #se a nfe já foi emitida para garantir é salvo novamente o endereço do xml e danfe
     elsif codigo_sefaz == 422

                    #TA FALTANDO UMA VERIFICAÇÃO AQUI
                     if res.body.to_s == '{"erros":[{"codigo":"erro_validacao_schema","mensagem":"Items 0 codigo ncm n\u00e3o \u00e9 do tamanho correto (precisa ter 8 caracteres)","campo":"items.0.codigo_ncm"}]}'
                     sweetalert_warning("Ocorreu um erro: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)
                     redirect_to invoice_path(@invoice) and return
                     end
                        res2 = http.get("/v2/nfe/consultar.json?ref=#{ref}&token=#{token}")
                        response = JSON.parse(res2.body)


                      if response['status'] == "erro_autorizacao"
                        sweetalert_warning(response['mensagem_sefaz'].force_encoding("UTF-8"), 'Aviso!', useRejections: false)
                        redirect_to invoice_path(@invoice) and return

                      elsif response['status'] != "processando_autorizacao"
                        puts "Body do RES3 = #{res2.body}"
                        @invoice = Invoice.find(params[:id])
                        Invoice.update(@invoice.id, status: 'NFE emitida Nº' + response['numero'], url_danfe: 'https://api.focusnfe.com.br' + response['caminho_danfe'], url_xml: 'https://api.focusnfe.com.br' + response['caminho_xml_nota_fiscal'])
                        #if @show_emitente.check_env == 'Produção'
                          #atualizando o ultimo numero da nota fiscal emitida
                        #  numero_ultima_nf = @ultima_nf_emitida.numero + 1
                        #  ConfigNf.update(@ultima_nf_emitida.id, numero: numero_ultima_nf)
                        #end
                        sweetalert_success("Nota fiscal foi emitida com sucesso: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Sucesso!', useRejections: false)
                        else
                        sweetalert_warning("Não houve tempo hábil para processar sua requisição, tente novamente: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)

                      redirect_to invoice_path(@invoice) and return
                      end
      elsif codigo_sefaz == 400
            sweetalert_warning("Atenção: " + "(" + "#{res.code}" + ")" + " #{res.body}".force_encoding("UTF-8"), 'Aviso!', useRejections: false)

     end

   end
 #render :json => hash
 redirect_to invoice_path(@invoice) and return

 end

  #verificar os dados para iniciar a emissão da NFe
  def gerar_nfe

    @invoice = Invoice.find(params[:id])

    #verifica se já é uma venda, caso contrário não permite a emissão da NFE

  if @invoice.status == 'ABERTA'
    sweetalert_warning('Você precisa finalizar primeiro esta venda para poder emitir uma Nota fiscal!', 'Aviso!', useRejections: false)
      redirect_to invoice_path(@invoice) and return
    elsif @invoice.type_invoice == 'NF emitida'
      sweetalert_warning('Você já emitiu uma nota fiscal para esta venda!', 'Aviso!', useRejections: false)
      redirect_to invoice_path(@invoice) and return
    elsif @invoice.type_invoice == 'Orçamento'
      sweetalert_warning('Você precisa converter este orçamento em venda primeiro para poder emitir a nota fiscal!', 'Aviso!', useRejections: false)

      redirect_to invoice_path(@invoice) and return
    end

     #VERIFICA SE SE TODOS OS PRODUTOS ADICIONADOS NA VENDA JÁ FORAM INFORMADOS OS IMPOSTOS PARA LIBERAR O BOTÃO
          #DE EMISSÃO DA NOTA FISCAL
           Item.where(invoice_id: @invoice).find_each do |item|
                if item.cfop.blank? || item.cfop == '' || item.codigo_ncm.blank? || item.codigo_ncm == '' || item.icms_situacao_tributaria.blank? || item.icms_situacao_tributaria == '' || item.pis_situacao_tributaria.blank? || item.pis_situacao_tributaria == '' || item.cofins_situacao_tributaria.blank? || item.cofins_situacao_tributaria == ''
                 @check_tributos = @check_tributos.to_s + ' ' + item.product.name.to_s + ', '
                 end
           end
                   if @check_tributos.present?
                   sweetalert_warning('Você não informou os tributos para o(s) produto(s): ' + @check_tributos, 'Aviso!', useRejections: false)
                   redirect_to invoice_path(@invoice) and return
                   end

    @show_emitente = ExpireDate.first
    @shippings = Shipping.order(:name)
    @estados = Estado.order(:sigla)
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)
  end


  #trazer os dados de ncm do produto quando selecionado
  def consulta_prod
    @product = Product.select('codigo_ncm,cest').where(name: params[:name]).first
    respond_to do |format|
    format.html
    format.json { render :json => @product }
    end
    #------------DEU CERTO GLORIA Á DEUS!!!-----------------------------------------------
  end

  #relatório
  def report_invoice

      if params[:date1].blank?
        params[:date1] = Date.today
        @datainicial = Date.today
      end

      if params[:date2].blank?
        params[:date2] = Date.today
      @datafinal = Date.today
      end

      @client = Client.find_by(id: params[:client_id])

           if params[:client_id].blank? && params[:nome_da_rota].blank?
             @invoices = Invoice.where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).order(:data_prevenda)
             @total_items = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:total_value_sale)
             @lucro_total = Invoice.select("invoices.id,invoices.type_invoice,items.total_value_sale,items.profit_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:profit_sale)
             @total_by_route = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').select("routes.name, count(invoices) as quantidade, Sum(items.total_value_sale) as total, Sum(items.profit_sale) as total_lucro").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).group('routes.name').order("routes.name")

           elsif params[:client_id].present?
             @invoices = Invoice.where(type_invoice: params[:tipo_consulta]).where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at).where("client_id = ?", params[:client_id]).order(:created_at)
             @total_items = Invoice.joins(:client).select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).sum(:total_value_sale)
             @lucro_total = Invoice.joins(:client).select("invoices.id,invoices.type_invoice,items.total_value_sale,items.profit_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).sum(:profit_sale)
             @total_by_route = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').select("routes.name, count(invoices) as quantidade, Sum(items.total_value_sale) as total, Sum(items.profit_sale) as total_lucro").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).where("client_id = ?", params[:client_id]).group('routes.name').order("routes.name")

           elsif params[:nome_da_rota].present?
             @invoices = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).order(:created_at).where("routes.name = ?", params[:nome_da_rota]).order(:created_at)
             @total_items = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').select("invoices.id,invoices.type_invoice,items.total_value_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).where("routes.name = ?", params[:nome_da_rota]).sum(:total_value_sale)
             @lucro_total = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').select("invoices.id,invoices.type_invoice,items.total_value_sale,items.profit_sale,invoices.created_at").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).where("routes.name = ?", params[:nome_da_rota]).sum(:profit_sale)
             @total_by_route = Invoice.joins('inner join clients on invoices.client_id = clients.id').joins('inner join routes on clients.route_id = routes.id').select("routes.name, count(invoices) as quantidade, Sum(items.total_value_sale) as total, Sum(items.profit_sale) as total_lucro").joins(:items).where(type_invoice: 'Venda').where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).where("routes.name = ?", params[:nome_da_rota]).group('routes.name').order("routes.name")

          end

    #render layout: false
  end



  #CONVERTE O ORÇAMENTO EM UMA INVOICE PASSANDO A BAIXA DOS PRODUTOS PARA O ESTOQUE
  def convert_invoice

    @invoice = Invoice.find(params[:id])


              #verifica se já existe algum item lançado, caso contrário não faz nada
              check_item = Item.find_by(invoice_id: @invoice.id)

                if check_item.blank?
                 sweetalert_warning('Insira pelo menos 1 item!', 'Aviso!', useRejections: false)
                 redirect_to invoice_path(@invoice) and return
                end

    Invoice.update(@invoice.id, type_invoice: 'Venda', status: 'Á RECEBER')

    #FAZENDO A SOMA DE TODOS OS ITENS PARA EXIBIR NA IMPRESSÃO
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)
    @total_items_cost = Item.where(invoice_id: @invoice.id).sum(:total_value_cost)
    @total_items_profit = Item.where(invoice_id: @invoice.id).sum(:profit_sale)

    #verifica a quantidade de parcelas e faz a divisão para enviar para o contas á receber
           @qnt_parcela = @invoice.installments.to_i

           #se tiver somente uma parcela é lançado uma vez só
           if @qnt_parcela == 1

                 #ENVIANDO PARA O CONTAS Á RECEBER
                 cta_receber = Receipt.new(params[:receipt])
                 cta_receber.doc_number = @invoice.id
                 cta_receber.client_id = @invoice.client_id
                 cta_receber.type_doc = "O.S"
                 cta_receber.discription = 'Referente a Venda: ' + params[:id].to_s

                 #total vendas
                 cta_receber.value_doc = @total_items
                 #total custo
                 cta_receber.t_cost = @total_items_cost
                 #total_lucro
                 cta_receber.t_profit = @total_items_profit

                 cta_receber.due_date = Date.today
                 cta_receber.installments = @invoice.installments
                 cta_receber.status = "Á RECEBER"
                 cta_receber.invoice_id = @invoice.id
                 cta_receber.form_receipt = @invoice.form_receipt
                 cta_receber.save!

            #caso contrário é feito um loop para lançar parcela por parcela
            else
                if @qnt_parcela > 1
                #@valor_total = Item.find_by[invoice_id: @invoice.id].sum(:total_value).to_f
                @resultado = @total_items.to_f / @qnt_parcela
                @resultado = (@resultado).round(2)

                #total cost
                @resultado_cost = @total_items_cost.to_f / @qnt_parcela
                @resultado_cost = (@resultado_cost).round(2)

                #total profit
                @resultado_profit = @total_items_profit.to_f / @qnt_parcela
                @resultado_profit = (@resultado_profit).round(2)

                @data_vencto = Date.today
                end

                    while @qnt_parcela > 0
                          @conta_parc = @conta_parc.to_i + 1
                          @data_vencto = @data_vencto.to_date + 1.month
                     #inserindo cada parcela no contas á receber
                     cta_receber = Receipt.new(params[:receipt])
                     cta_receber.doc_number = @invoice.id
                     cta_receber.client_id = @invoice.client_id
                     cta_receber.type_doc = "O.S"
                     cta_receber.discription = 'Referente a Venda: ' + params[:id].to_s + ' Parc. ' + @conta_parc.to_s
                     cta_receber.value_doc = @resultado
                     cta_receber.value_doc = @resultado_cost
                     cta_receber.value_doc = @resultado_profit
                     cta_receber.due_date = @data_vencto
                     cta_receber.installments = @invoice.installments.to_i
                     cta_receber.status = "Á RECEBER"
                     cta_receber.invoice_id = @invoice.id
                     cta_receber.form_receipt = @invoice.form_receipt
                     cta_receber.save!

                     @qnt_parcela = @qnt_parcela - 1

                    end
            end

    @invoice = Invoice.find(params[:id])

    render layout: 'reports/rpt_invoice' and return
    sweetalert_success('Orçamento convertido em O.S com sucesso!', 'Sucesso!', useRejections: false)

  end


  #EFETUA A BAIXA DA INVOICE e envia os dados para o contas á Receber automaticamente gerando o PDF
  def baixar
    @invoice = Invoice.find(params[:id])

    #FAZENDO A SOMA DE TODOS OS ITENS DA VENDA
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)

    #verifica se foi adicionado algum item na Invoice
    @qnt_items = Item.where(invoice_id: @invoice.id).count
      if @qnt_items == 0
        sweetalert_warning('Selecione pelo menos 1 item!', 'Atenção', persistent: 'OK')
       redirect_to invoice_path(@invoice) and return
      end

    #verifica se foi informada a forma de pagamento
    #if invoice_params[:form_receipt].blank?
    #  flash[:warning] = 'Selecione uma forma de pagamento válida!'
    #  redirect_to invoice_path(@invoice) and return
    #end

    #FAZENDO A SOMA DE TODOS OS ITENS PARA EXIBIR NA IMPRESSÃO
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)
    @lucro_total = Item.where(invoice_id: @invoice.id).sum(:profit_sale)

   #se for orçamento ele só gera a view para impressão
   if @invoice.type_invoice == 'Pré venda'

    Invoice.update(@invoice.id, form_receipt: '"DINHEIRO"', installments: 1, valor_total: @total_items)
     @invoice = Invoice.find(params[:id])
     sweetalert_success('Pré venda finalizada com sucesso!', 'Atenção', persistent: 'OK')
     redirect_to new_invoice_path and return
   end

    # SE JÁ FOI RECEBIDA A O.S. não enviará para o contar á Receber
     if @invoice.status == 'RECEBIDA'
        return

       else
         #verifica se foi marcada a baixa automática
         #PRECISO VER AQUI COMO VERIFICAR ESSA PARAMETRO!!!!!! AQUI TÁ O ERRO
         if invoice_params[:status] == '1'
         @novostatus = 'RECEBIDA'
         else
         @novostatus = 'Á RECEBER'
         end

       Invoice.update(@invoice.id, status: @novostatus, form_receipt: 'DINHEIRO', installments: 1, valor_total: @total_items)
       #FAZENDO A SOMA DE TODOS OS ITENS PARA JOGAR NO CONTAS Á RECEBER
       @total_items_cost = Item.where(invoice_id: @invoice.id).sum(:total_value_cost)
       @total_items_profit = Item.where(invoice_id: @invoice.id).sum(:profit_sale)
       @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)
       #verifica se já foi enviado para o contas á receber
       if Receipt.exists?(invoice_id: @invoice.id)
         #renderiza a view para carregar o PDF dentro da pasta Layouts/reports
         @invoice = Invoice.find(params[:id])
         #render layout: 'reports/rpt_invoice'

         else

           #verifica a quantidade de parcelas e faz a divisão para enviar para o contas á receber
           @qnt_parcela = 1

           #se tiver somente uma parcela é lançado uma vez só
           if @qnt_parcela == 1

                #ENVIANDO PARA O CONTAS Á RECEBER
                 cta_receber = Receipt.new(params[:receipt])
                 cta_receber.doc_number = @invoice.id
                 cta_receber.client_id = @invoice.client_id
                 cta_receber.type_doc = "O.S"
                 cta_receber.discription = 'Referente a Venda: ' + params[:id].to_s
                 #total vendas
                 cta_receber.value_doc = @total_items
                 #total custo
                 cta_receber.t_cost = @total_items_cost
                 #total_lucro
                 cta_receber.t_profit = @total_items_profit
                 cta_receber.due_date = Date.today
                 cta_receber.installments = 1
                 #Verifica se foi marcado para fazer a baixa automática
                 if invoice_params[:status] == '1'
                 cta_receber.status = "RECEBIDA"
                 cta_receber.receipt_date = Date.today
                 else
                 cta_receber.status = "Á RECEBER"
                 end
                 cta_receber.invoice_id = @invoice.id
                 cta_receber.form_receipt = 'DINHEIRO'
                 cta_receber.save!
            #caso contrário é feito um loop para lançar parcela por parcela
            else
                if @qnt_parcela > 1
                #@valor_total = Item.find_by[invoice_id: @invoice.id].sum(:total_value).to_f
                @resultado = @total_items.to_f / @qnt_parcela
                @resultado = (@resultado).round(2)
                @data_vencto = Date.today
                end

                    while @qnt_parcela > 0
                          @conta_parc = @conta_parc.to_i + 1
                          @data_vencto = @data_vencto.to_date + 1.month
                     #inserindo cada parcela no contas á receber
                     cta_receber = Receipt.new(params[:receipt])
                     cta_receber.doc_number = @invoice.id
                     cta_receber.client_id = @invoice.client_id
                     cta_receber.type_doc = "O.S"
                     cta_receber.discription = 'Referente a Venda: ' + @invoice.id.to_s + ' Parc. ' + @conta_parc.to_s
                     cta_receber.value_doc = @resultado
                     cta_receber.due_date = @data_vencto
                     cta_receber.installments = 1
                     #Verifica se foi marcado para fazer a baixa automática
                     if invoice_params[:status] == '1'
                     cta_receber.status = "RECEBIDA"
                     cta_receber.receipt_date = Date.today
                     else
                     cta_receber.status = "Á RECEBER"
                     end
                     cta_receber.invoice_id = @invoice.id
                     cta_receber.form_receipt = "DINHEIRO"
                     cta_receber.save!

                     @qnt_parcela = @qnt_parcela - 1

                    end

            end

        #Atualiza a forma de pagamento  na visualização do form
        @invoice = Invoice.find(params[:id])

        #renderiza a view para carregar o PDF dentro da pasta Layouts/reports
         #render layout: 'reports/rpt_invoice'
        puts invoice_params[:status]
        end
      end
  end


  # GET /invoices
  # GET /invoices.json
  def index

    check_client = Client.all
    if check_client.blank?
          sweetalert_warning('Não existe nenhum cliente cadastrado, portanto não será possivel gerar um orçamento ou Venda. Cadastre pelo menos 1 Cliente.', 'Aviso!', useRejections: false)
      redirect_to clients_path and return
    end
     check_product = Product.all
    if check_product.blank?
      sweetalert_warning('Não existe nenhum produto cadastrado, portanto não será possivel gerar um orçamento ou Venda. Cadastre pelo menos 1 Produto.', 'Aviso!', useRejections: false)
      redirect_to products_path and return
    end
    check_seller = Seller.all
    if check_seller.blank?
      sweetalert_warning('Não existe nenhum Vendedor cadastrado, portanto não será possivel gerar um orçamento ou Venda. Cadastre pelo menos 1 Vendedor.', 'Aviso!', useRejections: false)
      redirect_to sellers_path and return
    end

      if params[:date1].blank?
        params[:date1] = Date.today
        @datainicial = Date.today
      end

      if params[:date2].blank?
        params[:date2] = Date.today
      @datafinal = Date.today
      end
      if params[:nome_da_rota].blank?
      @invoices = Invoice.joins('inner join clients on clients.id = invoices.client_id').joins('inner join routes on routes.id = clients.route_id').where("data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).order('data_prevenda DESC')
    else params[:nome_da_rota].present?
      @invoices = Invoice.joins('inner join clients on clients.id = invoices.client_id').joins('inner join routes on routes.id = clients.route_id').where("data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).where('routes.name = ?', params[:nome_da_rota]).order('data_prevenda DESC')
    end

  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show

    @client = Client.find(@invoice.client_id)
    @total_items = Item.where(invoice_id: @invoice.id).sum(:total_value_sale)
    @lucro_total = Item.where(invoice_id: @invoice.id).sum(:profit_sale)
    @products = Product.order(:name)

  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
    if @invoice.type_invoice == 'Venda'
      sweetalert_warning('Não é possivel editar vendas.', 'Atenção!', persistent: 'OK')
      redirect_to invoices_path
    end
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)
    #@invoice.type_invoice = 'Venda'

    respond_to do |format|
      @invoice.status = 'ABERTA'
      @invoice.form_receipt = 'NÃO INFORMADO'
      @invoice.installments = '1'
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Criado com sucesso.' }
        format.json { render :show, status: :created, location: @invoice }
        #sweetalert_success('Dados cadastrados com sucesso!', 'Sucesso!', useRejections: false)
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    invoice_params[:data_prevenda] = Date.today
    respond_to do |format|
      puts 'esse é o id da venda ' + @invoice.id.to_s + invoice_params[:data_prevenda].to_s
      if @invoice.update(invoice_params)
        #ataualiza a data de prevenda em cada item lançado para o relatorio de analise geral
        #Item.where(invoice_id: @invoice.id).update_all(data_prevenda: invoice_params[:data_prevenda])
        format.html { redirect_to @invoice, notice: 'atualizado com sucesso.' }
        format.json { render :show, status: :ok, location: @invoice }
        sweetalert_success('Dados atualizados com sucesso!', 'Sucesso!', useRejections: false)
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
  def destroy
    @invoice.destroy

    Receipt.destroy_all(invoice_id: @invoice)
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Excluido com sucesso.' }
      sweetalert_success('Dados excluidos com sucesso!', 'Sucesso!', useRejections: false)
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:id, :shipping_id, :type_invoice, :client_id, :form_receipt, :installments, :status, :route_id, :t_cost, :t_profit,:natureza_operacao,:forma_pagamento_nf,:data_emissao,:data_entrada_saida,:tipo_documento,:finalidade_emissao,:icms_base_calculo,:icms_valor_total,:icms_base_calculo_st,:icms_valor_total_st,:valor_frete,:valor_seguro,:valor_total,:valor_produtos,:valor_ipi,:modalidade_frete,:informacoes_adicionais_contribuinte,:shipping,:veiculo_placa,:veiculo_uf,:veiculo_rntc,:quantidade_volume,:especie,:marca,:numero,:peso_bruto,:peso_liquido,:url_danfe,:url_xml,:justificativa_cancelamento,:just_correcao,:caminho_xml_correcao,:caminho_pdf_correcao,:caminho_xml_cancelamento, :valor_troco, :rota_id, :data_prevenda)
    end

    #mostra o nome dos clientes ao invés do id
    def show_client_name
      @clients = Client.order(:name)
    end
    def show_routes
      @routes = Route.order(:name)
    end


end
