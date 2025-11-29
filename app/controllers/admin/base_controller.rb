module Admin
  class BaseController < ApplicationController
    layout 'adminpanel'

    before_action :require_login
    before_action :require_admin

    private

    def require_login
      super
    end

    def require_admin
      super
    end
  end
end

