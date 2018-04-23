Rails.application.routes.draw do

  post :change_multiple_prevenda, to: "invoices#change_multiple_prevenda", as: :change_multiple_prevenda

  resources :routes
  resources :cancel_numerals
  resources :shippings
  resources :header_inputs do
    member do
      post 'baixar'
    end
  resources :item_inputs
  end

  resources :categ_payments
  resources :sellers
  resources :expire_dates
  resources :documents

resources :invoices do
 member do
   post 'baixar'
   get 'convert_invoice'
   get 'converter_venda'
   post 'nfe'
   get 'gerar_nfe'
 end
  resources :items
end

  resources :receipts
  resources :payments
  resources :products
  resources :suppliers
  resources :clients do
    member do
      get 'download'
      post 'baixa_comprovante'
    end
  end
  get 'rpt_compras', to: 'invoices#rpt_compras'

  resources :users

  #chama o form modal para o carregamento do XML
  get 'invoices/read_xml' => 'invoices#read_xml', :as => :read_xml
  #abrindo um form modal para carregar os links para download dos XML's e Danfes do mês anterior
  get 'pages/download_xml' => 'pages#download_xml', :as => :download_xml


    #chama a tela de cancelar intervalo de numeração a nfe
  get 'cancelar_numeracao', to: 'cancel_number_nves#cancelar_numeracao'
  #para efetivar o cancelamento de numeração da nfe
  post 'cancel_numeracao', to: 'invoices#cancel_numeracao'

  #para chamar a tela de consulta de NFCe emitida
  get 'consulta_nfe', to: 'invoices#consulta_nfe'
  #para consultar pelo codigo de referencia a NFCe
  get 'check_status', to: 'invoices#check_status'

   #para tela da carta de correção da nfe
  get 'corrige_nfe', to: 'invoices#corrige_nfe'
  #para efetivar o envio da carta de correção da nfe
  post 'correcao_nfe', to: 'invoices#correcao_nfe'

  #para cancelar a nfe
  get 'cancelar_nfe', to: 'invoices#cancelar_nfe'
  #para efetivar o cancelamento da nfe
  post 'cancel_nfe', to: 'invoices#cancel_nfe'



  #abrindo um form modal para informar os tributos do pruduto na invoice
  get 'items/editar_item' => 'items#editar_item', :as => :editar_item

  #abrindo um form modal para informar os tributos do pruduto na invoice
  get 'items/editar_tributo' => 'items#editar_tributo', :as => :editar_tributo

  #para editar os impostos no item da invoice
  get 'edit_imposto', to: 'items#edit_imposto'

  # para poder salvar os impostos nos itens já adicionados na venda
  resources :items


  #rota para consultar produto selecionado no combobox na Ordem de serviço
  get 'consulta_prod', to: 'invoices#consulta_prod'

  #pra fazer acerto por fornecedor
  post 'acerto_forn', to: 'payments#acerto_forn'
  #pra fazer acerto por fornecedor
  post 'acerto_cli', to: 'receipts#acerto_cli'

  #relatório de entrada de compras
  get 'report_input', to: 'header_inputs#report_input'

  #RELATÓRIO GERAL DE FECHAMENTO
  get 'report_fechamento', to: 'pages#report_fechamento'

  #rota para consultar produto selecionado no combobox na Ordem de serviço
  get 'consulta_prod', to: 'invoices#consulta_prod'

  root 'pages#index'

  get 'sessions/new'

  #rotas para o login
  get 'expired', to: 'sessions#expired_date'
  get 'pages/index'
  get 'login', to: 'sessions#new'
  delete 'logout', to: 'sessions#destroy'
  post 'login', to: 'sessions#create'
  #---------------------------------------------

  #rotas para contato
  get 'contact', to: 'messages#new', as: 'contact'
  post 'contact', to: 'messages#create'
  #---------------------------------------------
  #somente para chamar a edição do usuario quando for um membro logado
  get 'editar_user', to: 'users#chama_edicao'
  #---------------------------------------------

  #relatorio anual de vendas por mês
  get 'report_mensal', to: 'pages#report_mensal'

  #relatorio de notas fiscais emitidas
  get 'report_nfe', to: 'invoices#report_nfe'
  #---------------------------------------------

  #para relatório de vendedores
  get 'report_seller', to: 'sellers#report_seller'
  #----------------------------------------------

  #para relatório de categoria de despesas
  get 'report_categ', to: 'categ_payments#report_categ'
  #----------------------------------------------

  #para relatório de clientes
  get 'report_client', to: 'clients#report_client'
  #----------------------------------------------

  #para relatório de contas á pagar
  get 'report_payment', to: 'payments#report_payment'
  #----------------------------------------------

  #para relatório de produtos
  get 'report_product', to: 'products#report_product'
  #----------------------------------------------
  #para relatório de contas a receber
  get 'report_receipt', to: 'receipts#report_receipt'
  #----------------------------------------------
  #para relatório de fornecedores
  get 'report_supplier', to: 'suppliers#report_supplier'
  #----------------------------------------------
  #para relatório de Invoices
  get 'report_invoice', to: 'invoices#report_invoice'
  #----------------------------------------------

  #para carregar a view informando que não pode excluir cadastro com relacionamento em outra table
  get 'message_error_relation_tables', to: 'messages#message_error_relation_tables'
  end
