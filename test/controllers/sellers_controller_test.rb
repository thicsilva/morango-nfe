require 'test_helper'

class SellersControllerTest < ActionController::TestCase
  setup do
    @seller = sellers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:sellers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create seller" do
    assert_difference('Seller.count') do
      post :create, seller: { address: @seller.address, celphone: @seller.celphone, city: @seller.city, cpf: @seller.cpf, email: @seller.email, name: @seller.name, neighborhood: @seller.neighborhood, phone: @seller.phone, state: @seller.state, zipcode: @seller.zipcode }
    end

    assert_redirected_to seller_path(assigns(:seller))
  end

  test "should show seller" do
    get :show, id: @seller
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @seller
    assert_response :success
  end

  test "should update seller" do
    patch :update, id: @seller, seller: { address: @seller.address, celphone: @seller.celphone, city: @seller.city, cpf: @seller.cpf, email: @seller.email, name: @seller.name, neighborhood: @seller.neighborhood, phone: @seller.phone, state: @seller.state, zipcode: @seller.zipcode }
    assert_redirected_to seller_path(assigns(:seller))
  end

  test "should destroy seller" do
    assert_difference('Seller.count', -1) do
      delete :destroy, id: @seller
    end

    assert_redirected_to sellers_path
  end
end
