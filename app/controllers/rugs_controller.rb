class RugsController < ApplicationController
  before_action :set_rug, except: [:index, :new, :create]
  before_action :authenticate_user!, except: [:show, :preload, :preview]
  before_action :is_authorized, only: [:listing, :pricing, :description, :photo_upload, :amenities, :location, :update, :destroy]
  
  def index
    @rugs = current_user.rugs
  end

  def new
    @rug = current_user.rugs.build
  end

  def create
    # This code makes host register with Stripe first. We want people to create their listing without having to signup with Stripe first.
    # if !current_user.is_active_host
    #   return redirect_to payout_path, alert: "Please Connect to Stripe Express first."
    # end
    
    @rug = current_user.rugs.build(rug_params)
    if @rug.save
      redirect_to listing_rug_path(@rug), notice: "Saved..."
    else
      flash[:alert] = "Something went wrong..."
      render :new
    end
  end

  def show
    @photos = @rug.photos
    @guest_reviews = Review.where(type: "GuestReview")
  end
  
  def listing
  end

  def pricing
  end

  def description
  end

  def photo_upload
    @photos = @rug.photos
  end
  
  def amenities
  end

  def location
  end

  def update
    new_params = rug_params
    new_params = rug_params.merge(active: true) if is_ready_rug

    if @rug.update(new_params)
      flash[:notice] = "Saved..."
    else
      flash[:alert] = "Something went wrong..."
    end
    redirect_back(fallback_location: request.referer)
    # redirect_to rug_path(@rug), notice: "Saved..."
  end
  
  def destroy
    @rug = Rug.find(params[:id])
    @rug.destroy

    # redirect_back(fallback_location: request.referer, notice: "Deleted...!")
    redirect_to root_path, notice: "Deleted..."
  end
  
  #---- RESERVATIONS ----
  def preload
    today = Date.today
    reservations = @rug.reservations.where("(start_date >= ? OR end_date >= ?) AND status = ?", today, today, 1)
    unavailable_dates = @rug.calendars.where("status = ? AND day > ?", 1, today)

    special_dates = @rug.calendars.where("status = ? AND day > ? AND price <> ?", 0, today, @rug.price)
    
    render json: {
      reservations: reservations,
      unavailable_dates: unavailable_dates,
      special_dates: special_dates
    }
  end

  # def preview
  #   start_date = Date.parse(params[:start_date])
  #   end_date = Date.parse(params[:end_date])

  #   output = {
  #     conflict: is_conflict(start_date, end_date, @rug)
  #   }

  #   render json: output
  # end
  
  private
    # def is_conflict(start_date, end_date, rug)
    #   check = rug.reservations.where("(? < start_date AND end_date < ?) AND status = ?", start_date, end_date, 1)
    #   check_2 = rug.calendars.where("day BETWEEN ? AND ? AND status = ?", start_date, end_date, 1).limit(1)
      
    #   check.size > 0 || check_2.size > 0 ? true : false 
    # end

    def set_rug
      @rug = Rug.find(params[:id])
    end

    def is_authorized
      redirect_to root_path, alert: "You don't have permission" unless current_user.id == @rug.user_id
    end

    def is_ready_rug
      !@rug.active && !@rug.price.blank? && !@rug.listing_name.blank? && !@rug.photos.blank? && !@rug.address.blank?
    end

    def rug_params
      params.require(:rug).permit(:rug_type, :listing_name, :description,  :is_freeshipping, :address, :price, :active)
    end
end