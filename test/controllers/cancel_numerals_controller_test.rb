require 'test_helper'

class CancelNumeralsControllerTest < ActionController::TestCase
  setup do
    @cancel_numeral = cancel_numerals(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:cancel_numerals)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create cancel_numeral" do
    assert_difference('CancelNumeral.count') do
      post :create, cancel_numeral: { cnpj: @cancel_numeral.cnpj, final_number: @cancel_numeral.final_number, inicial_number: @cancel_numeral.inicial_number, justificativa: @cancel_numeral.justificativa, serie: @cancel_numeral.serie, url_xml: @cancel_numeral.url_xml, user: @cancel_numeral.user }
    end

    assert_redirected_to cancel_numeral_path(assigns(:cancel_numeral))
  end

  test "should show cancel_numeral" do
    get :show, id: @cancel_numeral
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @cancel_numeral
    assert_response :success
  end

  test "should update cancel_numeral" do
    patch :update, id: @cancel_numeral, cancel_numeral: { cnpj: @cancel_numeral.cnpj, final_number: @cancel_numeral.final_number, inicial_number: @cancel_numeral.inicial_number, justificativa: @cancel_numeral.justificativa, serie: @cancel_numeral.serie, url_xml: @cancel_numeral.url_xml, user: @cancel_numeral.user }
    assert_redirected_to cancel_numeral_path(assigns(:cancel_numeral))
  end

  test "should destroy cancel_numeral" do
    assert_difference('CancelNumeral.count', -1) do
      delete :destroy, id: @cancel_numeral
    end

    assert_redirected_to cancel_numerals_path
  end
end
