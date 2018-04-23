require 'test_helper'

class CategPaymentsControllerTest < ActionController::TestCase
  setup do
    @categ_payment = categ_payments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categ_payments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create categ_payment" do
    assert_difference('CategPayment.count') do
      post :create, categ_payment: { name: @categ_payment.name }
    end

    assert_redirected_to categ_payment_path(assigns(:categ_payment))
  end

  test "should show categ_payment" do
    get :show, id: @categ_payment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @categ_payment
    assert_response :success
  end

  test "should update categ_payment" do
    patch :update, id: @categ_payment, categ_payment: { name: @categ_payment.name }
    assert_redirected_to categ_payment_path(assigns(:categ_payment))
  end

  test "should destroy categ_payment" do
    assert_difference('CategPayment.count', -1) do
      delete :destroy, id: @categ_payment
    end

    assert_redirected_to categ_payments_path
  end
end
