class BouncehousesController < ApplicationController
  before_action :set_bouncehouse, except: [:index, :new, :create]
  before_action :authenticate_user!, except: [:show, :preload, :preview]
  before_action :is_authorized, only: [:listing, :pricing, :description, :photo_upload, :location, :update]
  
  def index
    @bouncehouses = current_user.bouncehouses
  end

  def new
    @bouncehouse = current_user.bouncehouses.build
  end

  def create
    # This code makes host register with Stripe first. We want people to create their listing without having to signup with Stripe first.
    # if !current_user.is_active_host
    #   return redirect_to payout_path, alert: "Please Connect to Stripe Express first."
    # end
    
    @bouncehouse = current_user.bouncehouses.build(bouncehouse_params)
    if @bouncehouse.save
      redirect_to listing_bouncehouse_path(@bouncehouse), notice: "Saved..."
    else
      flash[:alert] = "Something went wrong..."
      render :new
    end
  end

  def show
    @photos = @bouncehouse.photos
    @guest_reviews = Review.where(type: "GuestReview")
  end
  
  def listing
  end

  def pricing
  end

  def description
  end

  def photo_upload
    @photos = @bouncehouse.photos
  end

  def amenities
  end

  def location
  end

  def update
    new_params = bouncehouse_params
    new_params = bouncehouse_params.merge(active: true) if is_ready_bouncehouse

    if @bouncehouse.update(new_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
    end
    redirect_back(fallback_location: request.referer)
    # redirect_to bouncehouse_path(@bouncehouse), notice: "Saved..."
  end
  
  #---- RESERVATIONS ----
  def preload
    today = Date.today
    reservations = @bouncehouse.reservations.where("(start_date >= ? OR end_date >= ?) AND status = ?", today, today, 1)
    unavailable_dates = @bouncehouse.calendars.where("status = ? AND day > ?", 1, today)

    special_dates = @bouncehouse.calendars.where("status = ? AND day > ? AND price <> ?", 0, today, @bouncehouse.price)
    
    render json: {
      reservations: reservations,
      unavailable_dates: unavailable_dates,
      special_dates: special_dates
    }
  end

  def preview
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])

    output = {
      conflict: is_conflict(start_date, end_date, @bouncehouse)
    }

    render json: output
  end
  
  private
    def is_conflict(start_date, end_date, bouncehouse)
      check = bouncehouse.reservations.where("(? < start_date AND end_date < ?) AND status = ?", start_date, end_date, 1)
      check_2 = bouncehouse.calendars.where("day BETWEEN ? AND ? AND status = ?", start_date, end_date, 1).limit(1)
      
      check.size > 0 || check_2.size > 0 ? true : false 
    end

    def set_bouncehouse
      @bouncehouse = Bouncehouse.find(params[:id])
    end

    def is_authorized
      redirect_to root_path, alert: "You don't have permission" unless current_user.id == @bouncehouse.user_id
    end

    def is_ready_bouncehouse
      !@bouncehouse.active && !@bouncehouse.price.blank? && !@bouncehouse.listing_name.blank? && !@bouncehouse.photos.blank? && !@bouncehouse.address.blank?
    end

    def bouncehouse_params
      params.require(:bouncehouse).permit(:bouncehouse_type, :time_limit, :listing_name, :description, :address, 
      :price, :active, :instant)
    end
end