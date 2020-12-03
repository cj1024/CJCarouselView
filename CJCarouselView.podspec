Pod::Spec.new do |s|
  s.name             = 'CJCarouselView'
  s.version          = '0.1.0'
  s.summary          = 'A Simple Carousel View'
  s.description      = <<-DESC
Support Infinity Looping.
Support Horizontal An Vertical.
                       DESC

  s.homepage         = 'https://github.com/cj1024/CJCarouselView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cj1024' => 'jianchen1024@gmail.com' }
  s.source           = { :git => 'https://github.com/cj1024/CJCarouselView.git', :tag => s.version.to_s }
  s.screenshots      = 'https://i.postimg.cc/XqTx1vkr/2020-12-04-1-17-26.gif'

  s.ios.deployment_target = '9.0'

  s.source_files = 'CJCarouselView/Classes/**/*'
  s.public_header_files = 'Pod/Classes/*.h'
  s.public_header_files = 'Pod/Classes/Private/*.h'
  s.frameworks = 'UIKit'

end
