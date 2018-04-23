require 'test_helper'

class ItemInputsControllerTest < ActionController::TestCase
  setup do
    @item_input = item_inputs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:item_inputs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create item_input" do
    assert_difference('ItemInput.count') do
      post :create, item_input: { cost_value: @item_input.cost_value, header_input_id: @item_input.header_input_id, product_id: @item_input.product_id, qnt: @item_input.qnt, sale_value: @item_input.sale_value, total_value_cost: @item_input.total_value_cost, total_value_sale: @item_input.total_value_sale }
    end

    assert_redirected_to item_input_path(assigns(:item_input))
  end

  test "should show item_input" do
    get :show, id: @item_input
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @item_input
    assert_response :success
  end

  test "should update item_input" do
    patch :update, id: @item_input, item_input: { cost_value: @item_input.cost_value, header_input_id: @item_input.header_input_id, product_id: @item_input.product_id, qnt: @item_input.qnt, sale_value: @item_input.sale_value, total_value_cost: @item_input.total_value_cost, total_value_sale: @item_input.total_value_sale }
    assert_redirected_to item_input_path(assigns(:item_input))
  end

  test "should destroy item_input" do
    assert_difference('ItemInput.count', -1) do
      delete :destroy, id: @item_input
    end

    assert_redirected_to item_inputs_path
  end
end
