class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @bouncehouses = current_user.bouncehouses
  end
end