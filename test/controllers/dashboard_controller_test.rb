require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get overview" do
    get dashboard_overview_url
    assert_response :success
  end
end
