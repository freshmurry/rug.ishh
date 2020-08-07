module ApplicationHelper
  def avatar_url(user)
    if user.image
      "https://graph.facebook.com/#{user.uid}/picture?type=large"
    else  
      gravatar_id = Digest::MD5::hexdigest(user.email).downcase
      "https://www.gravatar.com/avatar/#{gravatar_id}.jpg?d=identical&s=150"
    end
  end
  
  def stripe_express_path
  # ----- TEST -----
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=http://localhost:3000/auth/stripe_connect/callback&client_id=ca_Bz12s2Z5ijkGknATCnWx9EmDZIvGMf0e&state={STATE_VALUE}"
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=http://localhost:3000/auth/stripe_connect/callback&client_id=ca_Bz12s2Z5ijkGknATCnWx9EmDZIvGMf0e&state=read_write"

  # ---- LIVE ----
  "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://bouncyhouse.herokuapp.com/auth/stripe_connect/callback&client_id=ca_Hms44phcleeZY7RlWjYEQM5K864Cfb1Q&state={STATE_VALUE}"
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://bouncehouse.com/auth/stripe_connect/callback&client_id=ca_Bz129rceytBvxCIxgLptuWQeV6JayofE&state=read_write"

  end
end