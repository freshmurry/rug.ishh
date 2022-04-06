class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @rugs = current_user.rugs
  end
end