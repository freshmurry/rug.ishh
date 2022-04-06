class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:approve, :decline]

  def create
    rug = Rug.find(params[:rug_id])

    # if current_user == rug.user
    #   flash[:alert] = "You cannot book your own Rug!"
    if current_user.stripe_id.blank?
       flash[:alert] = "Please update your payment method!"
       return redirect_to payment_method_path
    else
      start_date = Date.parse(reservation_params[:start_date])
      end_date = Date.parse(reservation_params[:end_date])
      days = (end_date - start_date).to_i + 1

      special_dates = rug.calendars.where(
        "status = ? AND day BETWEEN ? AND ? AND price <> ?",
        0, start_date, end_date, rug.price
      )
      
      @reservation = current_user.reservations.build(reservation_params)
      @reservation.rug = rug
      @reservation.price = rug.price
      # @reservation.total = rug.price * days
      # @reservation.save
      
      @reservation.total = rug.price * (days - special_dates.count)
      special_dates.each do |date|
          @reservation.total += date.price
      end
      
      if @reservation.Waiting!
        if rug.Request?
          flash[:notice] = "Request sent successfully"
        else
          charge(rug, @reservation)
        end
      else
        flash[:alert] = "Cannot make a reservation"
      end
      
    end
    redirect_to rug
  end

  def previous_reservations
    @spaces = current_user.reservations.order(start_date: :asc)
  end

  def current_reservations
    @rugs = current_user.rugs
  end
  
  def approve
    charge(@reservation.rug, @reservation)
    redirect_to current_reservations_path
  end

  def decline
    @reservation.Declined!
    redirect_to current_reservations_path
  end

  private
  
  def send_sms(rug, reservation)
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: '+3125488878',
      to: rug.user.phone_number,
      body: "#{reservation.user.fullname} booked your '#{rug.listing_name}'"
    )
  end
  
    def charge(rug, reservation)
      if !reservation.user.stripe_id.blank?
        customer = Stripe::Customer.retrieve(reservation.user.stripe_id)
        charge = Stripe::Charge.create(
          :customer => customer.id,
          :amount => reservation.total * 100,
          :description => rug.listing_name,
          :currency => "usd", 
          :destination => {
            :amount => reservation.total * 80, # 80% of the total amount goes to the Host, 20% is company fee
            :account => rug.user.merchant_id # rug's Stripe customer ID
          }
        )
  
        if charge
          reservation.Approved!
          ReservationMailer.send_email_to_guest(reservation.user, rug).deliver_later if reservation.user.setting.enable_email
          send_sms(rug, reservation) if rug.user.setting.enable_sms
          flash[:notice] = "Reservation created successfully!"
        else
          reservation.Declined!
          flash[:notice] = "Cannot charge with this payment method!"
        end
      end
    rescue Stripe::CardError => e  
      reservation.declined!
      flash[:notice] = e.message
    end
    
    def set_reservation
      @reservation = Reservation.find(params[:id])
    end
  
    def reservation_params
      params.require(:reservation).permit(:start_date, :end_date)
    end
end