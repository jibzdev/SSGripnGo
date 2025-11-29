# Use the official Ruby image as the base image
FROM ruby:3.2.2

# Install dependencies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client dos2unix

# Set the working directory inside the container
WORKDIR /myapp

# Copy the Gemfile and Gemfile.lock into the container
COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock

# Install the gems
RUN bundle install

RUN RAILS_ENV=production NODE_ENV=production bundle exec rails assets:precompile
RUN RAILS_ENV=production bundle exec rails db:migrate
# Copy the main application
COPY . /myapp
COPY public /myapp/public

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3001

# Start the main process
CMD ["rails", "server", "-b", "0.0.0.0"]
