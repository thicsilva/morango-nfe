require 'test_helper'

class HeaderInputsControllerTest < ActionController::TestCase
  setup do
    @header_input = header_inputs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:header_inputs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create header_input" do
    assert_difference('HeaderInput.count') do
      post :create, header_input: { client_id: @header_input.client_id }
    end

    assert_redirected_to header_input_path(assigns(:header_input))
  end

  test "should show header_input" do
    get :show, id: @header_input
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @header_input
    assert_response :success
  end

  test "should update header_input" do
    patch :update, id: @header_input, header_input: { client_id: @header_input.client_id }
    assert_redirected_to header_input_path(assigns(:header_input))
  end

  test "should destroy header_input" do
    assert_difference('HeaderInput.count', -1) do
      delete :destroy, id: @header_input
    end

    assert_redirected_to header_inputs_path
  end
end
