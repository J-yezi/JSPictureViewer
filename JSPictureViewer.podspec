Pod::Spec.new do |s|

s.name         = "JSPictureViewer"
s.version      = "0.0.5"
s.summary      = "图片浏览器"
s.description  = <<-DESC
                    picture viewer
                    DESC
s.homepage     = "https://github.com/J-yezi/JSPictureViewer"
s.license      = "MIT"
s.author       = { "J-yezi" => "yehao1020@gmail.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/J-yezi/JSPictureViewer.git", :tag => s.version }
s.source_files  = "JSPictureViewer/**/*.swift"
s.framework = "UIKit"
s.requires_arc = true
s.dependency "Kingfisher", "~> 3.11.0"

end
