class PagesController < ApplicationController
  #before_action :must_login

  #relatório de vendas anual por mês
  def report_mensal
    @result = Item.select("date_trunc( 'month', created_at ) as month, sum(total_value_sale) as total").group('month').order('month DESC').limit(13)
  end

  def download_xml
    #para verificar em qual ambiente está a App
    @show_emitente = ExpireDate.first
    port = @show_emitente.port.to_i

        puts 'ambiente de PRODUÇÃO e o SERVER é ' + @show_emitente.url_server_production.to_s + ' E TOKEN ' + @show_emitente.token_production.to_s
        server = @show_emitente.url_server_production.to_s;
        token = @show_emitente.token_production.to_s;
        cnpj = @show_emitente.cnpj.gsub(/[^0-9]/, '').to_s;
        valor_ssl = true
    require 'net/http'
    require 'json'
    Net::HTTP.start(server, port, use_ssl: valor_ssl, ) do |http|
      url = "http://api.focusnfe.com.br/backups/#{cnpj}.json?token=#{token}"
       res = http.get(url)
      response = JSON.parse(res.body)
      @download_danfe_xml = response['backups']
    end
      respond_to do |format|
    format.html
    format.js
    end
  end

  def index

    #total de vendas por mês - lucro BRUTO
      meeting_annual = Invoice.select("date_trunc( 'month', items.created_at ) as month, sum(items.total_value_sale) as total_quantity").joins(:items).group('month').order('month')
      meeting_by_month = []

      meeting_annual.each do |
      meeting |
      meeting_by_month.push({
          :label => meeting.month.strftime("%B"),
          :value => meeting.total_quantity
      })
      end

      @meeting_annual = Fusioncharts::Chart.new({
          :height => '30%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-m',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => meeting_by_month
          }
      })


    #total de vendas por mês - LUCRO BRUTO
      meeting_annual2 = Invoice.select("date_trunc( 'month', items.created_at ) as month, sum(items.total_value_cost) as total_quantity2").joins(:items).group('month').order('month')
      meeting_by_month2 = []

      meeting_annual2.each do |
      meeting |
      meeting_by_month2.push({
          :label => meeting.month.strftime("%B"),
          :value => meeting.total_quantity2
      })
      end

      @meeting_annual2 = Fusioncharts::Chart.new({
          :height => '30%',
          :width => '100%',
          :type => 'column2d',
          :renderAt => 'chart-container-m2',
          :dataSource => {
              :chart => {
                  :xAxisname => 'Representação gráfica por mes',
                  :yAxisName => 'Valores em (R$)',
                  :numberPrefix => 'R$',
                  :theme => 'fint',
                  :formatNumberScale=> '0',
                  :decimalSeparator=> ',',
                  :thousandSeparator=> '.',
              },
              :data => meeting_by_month2
          }
      })

    @date = DateTime.now.year

    #verifica se tem contas á pagar vencendo hoje
    @payments = Payment.where('due_date <= ?', Date.today).where(status: 'Á PAGAR').order(:due_date)
    @total_payments = Payment.where('due_date <= ?', Date.today).where(status: 'Á PAGAR').sum(:value_doc)

    #verifica se tem contas á receber vencendo hoje
    @receipts = Receipt.where('due_date <= ?', Date.today).where(status: 'Á RECEBER').order(:due_date)
    @total_receipts = Receipt.where('due_date <= ?', Date.today).where(status: 'Á RECEBER').sum(:value_doc)
  end

    #aproveitando esse controller pra gerar o fechamento por periodo
    def report_fechamento

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


        if params[:date1].present? && params[:date2].present? && params[:tipo_consulta] == 'Á RECEBER \ Á PAGAR'
           @total_receipts = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á RECEBER').sum(:value_doc)
           @total_custo = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á RECEBER').sum(:t_cost)
           @total_lucro_bruto = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á RECEBER').sum(:t_profit)
           @status_r = 'Á Receber'


           @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'Á PAGAR').sum(:value_doc)
           @status_p = 'Á Pagar'

        elsif params[:date1].present? && params[:date2].present? && params[:tipo_consulta] == 'RECEBIDAS \ PAGAS'
           @total_receipts = Receipt.where("receipt_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'RECEBIDA').sum(:value_doc)
           @total_custo = Receipt.where("receipt_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'RECEBIDA').sum(:t_cost)
           @total_lucro_bruto = Receipt.where("receipt_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'RECEBIDA').sum(:t_profit)
           @status_r = 'Recebidas'

           @total_payments = Payment.where("payment_date BETWEEN ? AND ?", params[:date1], params[:date2]).where(status: 'PAGA').sum(:value_doc)
           @status_p = 'Pagas'

        elsif params[:date1].present? && params[:date2].present? && params[:tipo_consulta].blank?
          #flash[:waning] = 'Estes dados são com base no dia de hoje, o que temos á Pagar e á Receber, pelo fato de não ter selecionado uma opção.'
           @total_receipts = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:value_doc)
           @total_custo = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:t_cost)
           @total_lucro_bruto = Receipt.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:t_profit)
           @status_r = ''

           @total_payments = Payment.where("due_date BETWEEN ? AND ?", params[:date1], params[:date2]).sum(:value_doc)
           @status_p = ''
        end

        #fazendo o calculo de vendas - despesas
        @total_liquido = @total_receipts.to_f - @total_payments.to_f
        @total_liquido = (@total_liquido).round(2)

      #se for por data
      #@total_items = Item.select("product_id, date(created_at) as created_at, sum(qnt) as qnt").where("created_at::date BETWEEN ? AND ?", params[:date1], params[:date2]).group("product_id,date(created_at)").order("created_at")

      @total_items = Item.joins(:invoice).select("product_id, sum(qnt) as qnt, sum(total_value_cost) as total_value_cost, sum(total_value_sale) as total_value_sale, sum(profit_sale) as profit_sale").where("invoices.type_invoice = 'Venda'").where("invoices.data_prevenda BETWEEN ? AND ?", params[:date1], params[:date2]).group("product_id")

    #render layout: false

    end

end
