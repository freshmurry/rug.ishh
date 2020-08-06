class ReservationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reservation, only: [:approve, :decline]

  def create
    bouncehouse = Bouncehouse.find(params[:bouncehouse_id])

    if current_user == bouncehouse.user
      flash[:alert] = "You cannot book your own Bouncehouse!"
    elsif current_user.stripe_id.blank?
       flash[:alert] = "Please update your payment method!"
       return redirect_to payment_method_path
    else
      start_date = Date.parse(reservation_params[:start_date])
      end_date = Date.parse(reservation_params[:end_date])
      days = (end_date - start_date).to_i + 1

      special_dates = bouncehouse.calendars.where(
        "status = ? AND day BETWEEN ? AND ? AND price <> ?",
        0, start_date, end_date, bouncehouse.price
      )
      
      @reservation = current_user.reservations.build(reservation_params)
      @reservation.bouncehouse = bouncehouse
      @reservation.price = bouncehouse.price
      # @reservation.total = bouncehouse.price * days
      # @reservation.save
      
      @reservation.total = bouncehouse.price * (days - special_dates.count)
      special_dates.each do |date|
          @reservation.total += date.price
      end
      
      if @reservation.Waiting!
        if bouncehouse.Request?
          flash[:notice] = "Request sent successfully"
        else
          charge(bouncehouse, @reservation)
        end
      else
        flash[:alert] = "Cannot make a reservation"
      end
      
    end
    redirect_to bouncehouse
  end

  def previous_reservations
    @spaces = current_user.reservations.order(start_date: :asc)
  end

  def current_reservations
    @bouncehouses = current_user.bouncehouses
  end
  
  def approve
    charge(@reservation.bouncehouse, @reservation)
    redirect_to current_reservations_path
  end

  def decline
    @reservation.Declined!
    redirect_to current_reservations_path
  end

  private
  
  def send_sms(bouncehouse, reservation)
    @client = Twilio::REST::Client.new
    @client.messages.create(
      from: '+3125488878',
      to: bouncehouse.user.phone_number,
      body: "#{reservation.user.fullname} booked your '#{bouncehouse.listing_name}'"
    )
  end
  
    def charge(bouncehouse, reservation)
      if !reservation.user.stripe_id.blank?
        customer = Stripe::Customer.retrieve(reservation.user.stripe_id)
        charge = Stripe::Charge.create(
          :customer => customer.id,
          :amount => reservation.total * 100,
          :description => bouncehouse.listing_name,
          :currency => "usd", 
          :destination => {
            :amount => reservation.total * 80, # 80% of the total amount goes to the Host, 20% is company fee
            :account => bouncehouse.user.merchant_id # bouncehouse's Stripe customer ID
          }
        )
  
        if charge
          reservation.Approved!
          ReservationMailer.send_email_to_guest(reservation.user, bouncehouse).deliver_later if reservation.user.setting.enable_email
          send_sms(bouncehouse, reservation) if bouncehouse.user.setting.enable_sms
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