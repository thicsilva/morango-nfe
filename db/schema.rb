# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180404123607) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cancel_numerals", force: :cascade do |t|
    t.string   "cnpj"
    t.string   "user"
    t.integer  "serie"
    t.integer  "inicial_number"
    t.integer  "final_number"
    t.string   "justificativa"
    t.string   "url_xml"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "categ_payments", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cfops", force: :cascade do |t|
    t.integer  "codigo"
    t.string   "descricao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cidades", force: :cascade do |t|
    t.string   "nome"
    t.integer  "estado_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["estado_id"], name: "index_cidades_on_estado_id", using: :btree
  end

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "cnpj"
    t.string   "cellphone"
    t.string   "email"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "cidade_id"
    t.integer  "estado_id"
    t.string   "contact_name"
    t.integer  "seller_id"
    t.string   "cpf"
    t.string   "numero"
    t.string   "complemento"
    t.string   "cod_municipio"
    t.string   "indicador_inscr"
    t.string   "inscr_est"
    t.string   "inscr_suframa"
    t.string   "inscr_municipal"
    t.string   "codigo_pais"
    t.string   "pais"
    t.integer  "route_id"
    t.integer  "position"
    t.index ["cidade_id"], name: "index_clients_on_cidade_id", using: :btree
    t.index ["estado_id"], name: "index_clients_on_estado_id", using: :btree
    t.index ["route_id"], name: "index_clients_on_route_id", using: :btree
    t.index ["seller_id"], name: "index_clients_on_seller_id", using: :btree
  end

  create_table "documents", force: :cascade do |t|
    t.string   "filename"
    t.string   "content_type"
    t.binary   "file_contents"
    t.string   "owner"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "estados", force: :cascade do |t|
    t.string   "sigla"
    t.string   "nome"
    t.integer  "capital_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["capital_id"], name: "index_estados_on_capital_id", using: :btree
  end

  create_table "expire_dates", force: :cascade do |t|
    t.date     "date_expire"
    t.boolean  "active"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.string   "razao"
    t.string   "nome_fantasia"
    t.string   "cnpj"
    t.string   "cep"
    t.string   "endereco"
    t.integer  "numero"
    t.string   "bairro"
    t.string   "cidade"
    t.string   "uf"
    t.string   "telefone"
    t.string   "inscricao"
    t.boolean  "check_date"
    t.date     "expiration_date"
    t.string   "check_env"
    t.string   "url_server_test"
    t.string   "token_test"
    t.string   "url_server_production"
    t.string   "token_production"
    t.integer  "port"
    t.integer  "sleep"
    t.date     "updated_cost"
  end

  create_table "header_inputs", force: :cascade do |t|
    t.integer  "supplier_id"
    t.string   "form_payment"
    t.string   "status"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["supplier_id"], name: "index_header_inputs_on_supplier_id", using: :btree
  end

  create_table "invoices", force: :cascade do |t|
    t.string   "type_invoice"
    t.integer  "client_id"
    t.string   "status_invoice"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "status"
    t.string   "form_receipt"
    t.integer  "installments"
    t.string   "route"
    t.string   "natureza_operacao"
    t.integer  "forma_pagamento_nf"
    t.date     "data_emissao"
    t.date     "data_entrada_saida"
    t.integer  "tipo_documento"
    t.integer  "finalidade_emissao"
    t.decimal  "icms_base_calculo"
    t.decimal  "icms_valor_total"
    t.decimal  "icms_base_calculo_st"
    t.decimal  "icms_valor_total_st"
    t.decimal  "valor_frete"
    t.decimal  "valor_seguro"
    t.decimal  "valor_total"
    t.decimal  "valor_produtos"
    t.decimal  "valor_ipi"
    t.integer  "modalidade_frete"
    t.text     "informacoes_adicionais_contribuinte"
    t.integer  "shipping_id"
    t.string   "veiculo_placa"
    t.string   "veiculo_uf"
    t.string   "veiculo_rntc"
    t.integer  "quantidade_volume"
    t.string   "especie"
    t.string   "marca"
    t.string   "numero"
    t.decimal  "peso_bruto"
    t.decimal  "peso_liquido"
    t.string   "url_danfe"
    t.string   "url_xml"
    t.string   "justificativa_cancelamento"
    t.string   "just_correcao"
    t.string   "caminho_xml_correcao"
    t.string   "caminho_pdf_correcao"
    t.string   "caminho_xml_cancelamento"
    t.decimal  "valor_troco"
    t.date     "data_prevenda"
    t.index ["client_id"], name: "index_invoices_on_client_id", using: :btree
    t.index ["shipping_id"], name: "index_invoices_on_shipping_id", using: :btree
  end

  create_table "item_inputs", force: :cascade do |t|
    t.integer  "product_id"
    t.decimal  "cost_value"
    t.integer  "qnt"
    t.decimal  "total_value_cost"
    t.integer  "header_input_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "cest"
    t.boolean  "escala_relevante"
    t.string   "cnpj_fabricante"
    t.string   "codigo_beneficio_fiscal_uf"
    t.index ["header_input_id"], name: "index_item_inputs_on_header_input_id", using: :btree
    t.index ["product_id"], name: "index_item_inputs_on_product_id", using: :btree
  end

  create_table "items", force: :cascade do |t|
    t.integer  "qnt"
    t.decimal  "cost_value"
    t.decimal  "sale_value"
    t.decimal  "total_value_cost"
    t.decimal  "total_value_sale"
    t.integer  "product_id"
    t.integer  "invoice_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "codigo_ncm"
    t.decimal  "profit_sale"
    t.integer  "cfop"
    t.string   "ipi_situacao_tributaria"
    t.string   "icms_situacao_tributaria"
    t.string   "pis_situacao_tributaria"
    t.string   "cofins_situacao_tributaria"
    t.decimal  "valor_frete"
    t.decimal  "valor_seguro"
    t.integer  "cest"
    t.boolean  "escala_relevante"
    t.string   "cnpj_fabricante"
    t.string   "codigo_beneficio_fiscal_uf"
    t.decimal  "fcp_percentual_uf_destino"
    t.decimal  "fcp_valor_uf_destino"
    t.decimal  "fcp_base_calculo_uf_destino"
    t.date     "data_prevenda"
    t.index ["invoice_id"], name: "index_items_on_invoice_id", using: :btree
    t.index ["product_id"], name: "index_items_on_product_id", using: :btree
  end

  create_table "messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments", force: :cascade do |t|
    t.string   "doc_number"
    t.string   "description"
    t.date     "due_date"
    t.date     "payment_date"
    t.integer  "installments"
    t.decimal  "value_doc"
    t.integer  "supplier_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "type_doc"
    t.string   "status"
    t.string   "form_payment"
    t.integer  "categ_payment_id"
    t.integer  "header_input_id"
    t.index ["categ_payment_id"], name: "index_payments_on_categ_payment_id", using: :btree
    t.index ["supplier_id"], name: "index_payments_on_supplier_id", using: :btree
  end

  create_table "products", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.string   "unidade_comercial"
    t.string   "codigo_ncm"
    t.decimal  "cost_value"
    t.date     "data_atualizacao_custo"
  end

  create_table "receipts", force: :cascade do |t|
    t.string   "doc_number"
    t.string   "type_doc"
    t.string   "discription"
    t.date     "due_date"
    t.date     "receipt_date"
    t.integer  "installments"
    t.decimal  "value_doc"
    t.integer  "client_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "status"
    t.integer  "invoice_id"
    t.string   "form_receipt"
    t.decimal  "t_cost"
    t.decimal  "t_profit"
    t.index ["client_id"], name: "index_receipts_on_client_id", using: :btree
  end

  create_table "routes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sellers", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "celphone"
    t.string   "cpf"
    t.string   "email"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "cidade_id"
    t.integer  "estado_id"
    t.string   "municipio"
    t.string   "uf"
    t.index ["cidade_id"], name: "index_sellers_on_cidade_id", using: :btree
    t.index ["estado_id"], name: "index_sellers_on_estado_id", using: :btree
  end

  create_table "shippings", force: :cascade do |t|
    t.string   "name"
    t.string   "cep"
    t.string   "address"
    t.string   "neighborhood"
    t.string   "city"
    t.string   "state"
    t.string   "phone"
    t.string   "cnpj"
    t.string   "inscricao"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "cpf"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name"
    t.string   "address"
    t.string   "neighborhood"
    t.string   "zipcode"
    t.string   "phone"
    t.string   "cellphone"
    t.string   "cpf_cnpj"
    t.string   "email"
    t.integer  "cidade_id"
    t.integer  "estado_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "city"
    t.string   "state"
    t.index ["cidade_id"], name: "index_suppliers_on_cidade_id", using: :btree
    t.index ["estado_id"], name: "index_suppliers_on_estado_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.string   "password_digest"
    t.string   "type_access"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "ccli"
    t.boolean  "cforn"
    t.boolean  "cprod"
    t.boolean  "ccateg"
    t.boolean  "cvend"
    t.boolean  "cuser"
    t.boolean  "mos"
    t.boolean  "fpag"
    t.boolean  "frec"
    t.boolean  "rcli"
    t.boolean  "rforn"
    t.boolean  "rprod"
    t.boolean  "rpag"
    t.boolean  "rrec"
    t.boolean  "rcateg"
    t.boolean  "rvend"
    t.boolean  "mupload"
    t.boolean  "rfecha"
    t.boolean  "minput"
    t.boolean  "shipping"
    t.boolean  "mconsul_nfe"
    t.boolean  "mcancel_number"
    t.boolean  "rnfe"
    t.boolean  "c_route"
    t.boolean  "r_compra"
  end

  add_foreign_key "clients", "cidades"
  add_foreign_key "clients", "estados"
  add_foreign_key "clients", "routes"
  add_foreign_key "clients", "sellers"
  add_foreign_key "header_inputs", "suppliers"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "shippings"
  add_foreign_key "item_inputs", "header_inputs"
  add_foreign_key "item_inputs", "products"
  add_foreign_key "items", "invoices"
  add_foreign_key "items", "products"
  add_foreign_key "payments", "categ_payments"
  add_foreign_key "payments", "suppliers"
  add_foreign_key "receipts", "clients"
  add_foreign_key "sellers", "cidades"
  add_foreign_key "sellers", "estados"
  add_foreign_key "suppliers", "cidades"
  add_foreign_key "suppliers", "estados"
end
