require 'test_helper'

class ExpireDatesControllerTest < ActionController::TestCase
  setup do
    @expire_date = expire_dates(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:expire_dates)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create expire_date" do
    assert_difference('ExpireDate.count') do
      post :create, expire_date: { active: @expire_date.active, date_expire: @expire_date.date_expire }
    end

    assert_redirected_to expire_date_path(assigns(:expire_date))
  end

  test "should show expire_date" do
    get :show, id: @expire_date
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @expire_date
    assert_response :success
  end

  test "should update expire_date" do
    patch :update, id: @expire_date, expire_date: { active: @expire_date.active, date_expire: @expire_date.date_expire }
    assert_redirected_to expire_date_path(assigns(:expire_date))
  end

  test "should destroy expire_date" do
    assert_difference('ExpireDate.count', -1) do
      delete :destroy, id: @expire_date
    end

    assert_redirected_to expire_dates_path
  end
end
