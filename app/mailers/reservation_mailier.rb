class ReservationMailer < ApplicationMailer
  def send_email_to_guest(guest, bouncehouse)
    @recipient = guest
    @bouncehouse = bouncehouse
    mail(to: @recipient.email, subject: "Thank you! Enjoy your bounce house rental!💯")
  end
end