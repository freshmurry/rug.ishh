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
  "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://connect.stripe.com/connect/default/oauth/test&client_id=ca_JTqdRf8V2CW9ExyXQpkHrheJYb8ZXUyP&state={STATE_VALUE}"
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=http:/https://a7c19537997643e2a4634d64c8f61def.vfs.cloud9.us-east-1.amazonaws.com/auth/stripe_connect/callback&client_id=ca_JTqduEaxkD5FRo73R7UnPDrGrA2HrYb4&state={STATE_VALUE}"
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://a7c19537997643e2a4634d64c8f61def.vfs.cloud9.us-east-1.amazonaws.com/auth/stripe_connect/callback&client_id=ca_JTqduEaxkD5FRo73R7UnPDrGrA2HrYb4&state=read_write"

  # ---- LIVE ----
  # "https://connect.stripe.com/express/oauth/authorize?redirect_uri=https://www.berwynbouncehouse.com/auth/stripe_connect/callback&client_id=ca_JTqduEaxkD5FRo73R7UnPDrGrA2HrYb4&state={STATE_VALUE}"
  end
end