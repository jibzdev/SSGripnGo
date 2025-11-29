ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "bcrypt"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors, with: :threads)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  def sign_in_as(user, password: "Password123!")
    user.update_column(:password_digest, BCrypt::Password.create(password))
    post "/auth/login", params: { email: user.email, password: password }
  end
end
