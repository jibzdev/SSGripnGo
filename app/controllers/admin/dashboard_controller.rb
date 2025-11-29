module Admin
  class DashboardController < BaseController
    def overview
      @total_users = User.count
      @total_orders = Order.count
      @open_orders = Order.where.not(status: %w[fulfilled cancelled]).count
      @total_revenue = Order.sum(:total)

      @recent_orders = Order.order(created_at: :desc).limit(10)
      @recent_activities = Activity.order(created_at: :desc).limit(10)
    end

    def analytics
      range = analytics_range
      scoped_orders = Order.where(created_at: range)

      orders_grouped = scoped_orders.group(group_by_date_clause).order(group_by_date_clause).count
      revenue_grouped = scoped_orders.group(group_by_date_clause).order(group_by_date_clause).sum(:total)

      @orders_by_day = format_grouped_series(orders_grouped)
      @revenue_by_day = format_grouped_series(revenue_grouped)
    end

    def reports
      @order_report = {
        total: Order.count,
        pending: Order.where(status: 'pending').count,
        fulfilled: Order.where(status: 'fulfilled').count,
        cancelled: Order.where(status: 'cancelled').count,
        revenue: Order.sum(:total)
      }
    end

    def activity_live_view
      @recent_activities = Activity.includes(:user).order(created_at: :desc).limit(25)
    end

    private

    def analytics_range
      days = params.fetch(:days, 14).to_i
      days = 1 if days < 1
      days.days.ago.beginning_of_day..Time.current
    end

    def group_by_date_clause
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('sqlite')
        Arel.sql("DATE(created_at)")
      else
        Arel.sql("DATE_TRUNC('day', created_at)")
      end
    end

    def format_grouped_series(grouped_hash)
      grouped_hash.map do |group_key, value|
        [format_day_label(group_key), value]
      end
    end

    def format_day_label(group_key)
      day =
        case group_key
        when Time, ActiveSupport::TimeWithZone
          group_key.to_date
        when Date
          group_key
        else
          Date.parse(group_key.to_s)
        end
      day.strftime('%b %d')
    rescue ArgumentError
      group_key.to_s
    end
  end
end

