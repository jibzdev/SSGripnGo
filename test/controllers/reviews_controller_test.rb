require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @review_params = {
      review: {
        rating: 5,
        title: "Track ready",
        body: "Balanced feedback and phenomenal grip. Easily my favorite upgrade."
      }
    }
  end

  test "should get index" do
    get reviews_url
    assert_response :success
  end

  test "should require login for create" do
    post reviews_url, params: @review_params
    assert_redirected_to login_url
  end

  test "logged in user can create review" do
    user = User.create!(
      username: "reviewer",
      email: "reviewer@example.com",
      password: "Password123!",
      password_confirmation: "Password123!"
    )
    sign_in_as(user)
    assert_difference("Review.count", 1) do
      post reviews_url, params: @review_params
    end
    assert_redirected_to reviews_url
  end
end

