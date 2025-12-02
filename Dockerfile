# Use the official Ruby image as the base image
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client dos2unix

# Set the working directory inside the container
WORKDIR /myapp

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile Gemfile.lock ./

# Install the gems
RUN bundle install

# Copy the main application
COPY . .

# Precompile assets
RUN RAILS_ENV=production NODE_ENV=production bundle exec rails assets:precompile

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN dos2unix /usr/bin/entrypoint.sh && chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3001

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
