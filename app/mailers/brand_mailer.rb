class BrandMailer < ActionMailer::Base
  default from: "brandbuddee <andykaruza@brandbuddee.com>"

  def reset_password(brand, root_url)
   @brand = brand
   @url = root_url
   mail :to => brand.email, :subject => "brandbuddee - Brand Account Password Reset", :from => "brandbuddee <andykaruza@brandbuddee.com>"
  end

  def post_signup(email, root_url)
  	@email = email
  	@url = root_url
  	mail :to => email, :subject => "brandbuddee - Thanks for Becoming a Brand!", :from => "brandbuddee <andykaruza@brandbuddee.com>"
  end

  def profile_completion(brand, root_url)
  	
  end
end
