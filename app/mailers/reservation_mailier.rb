class ReservationMailer < ApplicationMailer
  def send_email_to_guest(guest, rug)
    @recipient = guest
    @rug = rug
    mail(to: @recipient.email, subject: "Thank you! Sit tight, we are working on your rug!💯")
  end
end