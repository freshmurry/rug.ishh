Rails.configuration.stripe = {
  #---- TEST ----
  # :publishable_key => 'pk_test_51IqqNyLs2KRAx7O74Rco5xBGzF09TqvyYGQsQMP44sUuI7iOYmk1JsQi6CtsmJNhnt3mWNhi1SCUb9tgVsVEl9lV00KKiSVdfh',
  # :secret_key => 'sk_test_51IqqNyLs2KRAx7O7IV1qUi4xuqJWN1kotmRDm2ECPOMvCEVtSkCKye0SibKd1lUWp1aSSI9oNNUfu8vknfwmvdJv00s6XHBtWZ'
  
  #---- LIVE ----
  :publishable_key => ENV['STRIPE_PUBLISHABLE_KEY'],
  :secret_key      => ENV['STRIPE_SECRET_KEY']
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]