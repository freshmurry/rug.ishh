class PagesController < ApplicationController
  def home
    @bouncehouses = Bouncehouse.where(active: true).limit(3)
  end

  def search
    # STEP 1
    if params[:search].present? && params[:search].strip != ""
      session[:loc_search] = params[:search]
    end

    # STEP 2
    if session[:loc_search] && session[:loc_search] != ""
      @bouncehouses_address = Bouncehouse.where(active: true).near(session[:loc_search], 5, order: 'distance')
    else
      @bouncehouses_address = Bouncehouse.where(active: true).all
    end

    # STEP 3
    @search = @bouncehouses_address.ransack(params[:q])
    @bouncehouses = @search.result

    @arrBouncehouses = @bouncehouses.to_a

    # STEP 4
    if (params[:start_date] && params[:end_date] && !params[:start_date].empty? &&  !params[:end_date].empty?)
      
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date])

      @bouncehouses.each do |bouncehouse|

        not_available = bouncehouse.reservations.where(
          "((? <= start_date AND start_date <= ?)
          OR (? <= end_date AND end_date <= ?)
          OR (start_date < ? AND ? < end_date))
          AND status = ?",
          start_date, end_date,
          start_date, end_date,
          start_date, end_date,
          1
        ).limit(1)
        
        not_available_in_calendar = Calendar.where(
          "bouncehouse_id = ? AND status = ? AND day <= ? AND day >= ?",
          bouncehouse.id, 1, end_date, start_date
        ).limit(1)
        
        if not_available.length > 0 || not_available_in_calendar.length > 0
          @arrBouncehouses.delete(bouncehouse)
        end
      end
    end

  end
end