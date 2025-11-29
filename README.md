# RK Customs - Automotive Services Booking System

A Rails application for managing automotive service bookings with email notifications via AWS SES.

## Features

- User authentication and authorization
- Service booking system
- Email notifications via AWS SES
- Admin dashboard
- Payment processing with Stripe
- Calendar integration with ICS files

## Email Configuration

This application uses AWS SES for sending emails. To configure:

1. Set up AWS SES in your AWS account
2. Verify your domain or email addresses in SES
3. Set the following environment variables:
   ```
   AWS_ACCESS_KEY_ID=your_aws_access_key_id
   AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
   AWS_REGION=us-east-1
   ```

## Development Setup

1. Clone the repository
2. Run `bundle install`
3. Set up your environment variables
4. Run `rails db:migrate`
5. Start the server with `rails server`

## Testing Email

Visit `/book/test-aws-ses-email` to test AWS SES email delivery.

## Finished

- Migrating to rails
- Basic authentication and placeholder dashboard
- AWS SES email integration
- Booking system with email notifications

## In progress

- Currently working on a landing page

## Things needed to be done
 - logo
 - name
 - domain name

![image](https://github.com/user-attachments/assets/5cf07e3e-cf3e-4c13-bbb3-5b9a73b87fdf)
