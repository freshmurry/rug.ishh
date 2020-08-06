class CalendarsController < ApplicationController
  before_action :authenticate_user!
  include ApplicationHelper

  def create
    date_from = Date.parse(calendar_params[:start_date])
    date_to = Date.parse(calendar_params[:end_date])

    (date_from..date_to).each do |date|
      calendar = Calendar.where(bouncehouse_id: params[:bouncehouse_id], day: date)

      if calendar.present?
        calendar.update_all(price: calendar_params[:price], status: calendar_params[:status])
      else
        Calendar.create(
          bouncehouse_id: params[:bouncehouse_id],
          day: date,
          price: calendar_params[:price],
          status: calendar_params[:status]
        )
      end
    end

    redirect_to host_calendar_path
  end
  
  def host
    @bouncehouses = current_user.bouncehouses

    params[:start_date] ||= Date.current.to_s
    params[:bouncehouse_id] ||= @bouncehouses[0] ? @bouncehouses[0].id : nil

    if params[:q].present?
      params[:start_date] = params[:q][:start_date]
      params[:bouncehouse_id] = params[:q][:bouncehouse_id]
    end

    @search = Reservation.ransack(params[:q])
  
    if params[:bouncehouse_id]
      @bouncehouse = Bouncehouse.find(params[:bouncehouse_id])
      start_date = Date.parse(params[:start_date])

      first_of_month = (start_date - 1.months).beginning_of_month # => Jun 1
      end_of_month = (start_date + 1.months).end_of_month # => Aug 31

      @events = @bouncehouse.reservations.joins(:user)
                      .select('reservations.*, users.fullname, users.image, users.email, users.uid')
                      .where('(start_date BETWEEN ? AND ?) AND status <> ?', first_of_month, end_of_month, 3)
      @events.each{ |e| e.image = image_url(e) }
      @days = Calendar.where("bouncehouse_id = ? AND day BETWEEN ? AND ?", params[:bouncehouse_id], first_of_month, end_of_month)
    else
      @bouncehouse = nil
      @events = []
      @days = []
    end
  end

  private
    def calendar_params
      params.require(:calendar).permit([:price, :status, :start_date, :end_date])
    end
end