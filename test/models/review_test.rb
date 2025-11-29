require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @review = reviews(:one)
  end

  test "fixture is valid" do
    assert @review.valid?
  end

  test "requires rating within range" do
    review = Review.new(user: @user, rating: 6, title: "Too high", body: "Invalid rating should not be allowed for reviews.")
    assert_not review.valid?
    assert_includes review.errors[:rating], "is not included in the list"
  end

  test "enforces one review per user" do
    duplicate = Review.new(user: @review.user, rating: 4, title: "Duplicate", body: "Trying to add a second review for same user.")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end
end

