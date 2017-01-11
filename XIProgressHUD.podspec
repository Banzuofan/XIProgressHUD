
Pod::Spec.new do |s|

  s.name         = "XIProgressHUD"
  s.version      = "0.0.1"
  s.summary      = "A short description of XIProgressHUD."

  s.description  = "https://github.com/Banzuofan/XIProgressHUD.git"

  s.homepage     = "https://github.com/Banzuofan/XIProgressHUD.git"

  s.license      = "MIT (example)"


  s.author             = { "YXLONG" => "banzuofan@hotmail.com" }
  
  s.platform     = :ios, "5.0"

  s.source       = { :git => "https://github.com/Banzuofan/XIProgressHUD.git", :tag => "#{s.version}" }

  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"
end
