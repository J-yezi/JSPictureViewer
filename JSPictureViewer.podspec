Pod::Spec.new do |s|

    s.name         = 'JSPictureViewer'
    s.version      = '0.0.8'
    s.summary      = '图片浏览器'
    s.homepage     = 'https://github.com/J-yezi/JSPictureViewer'
    s.license      = 'MIT'
    s.author       = { 'J-yezi' => 'yehao1020@gmail.com' }
    s.source       = { :git => 'https://github.com/J-yezi/JSPictureViewer.git', :tag => s.version }

    s.ios.deployment_target = '8.0'

    s.source_files  = 'JSPictureViewer/**/*.swift'
    s.framework = 'UIKit'
    s.dependency 'Kingfisher', '~> 4.8.1'

end
