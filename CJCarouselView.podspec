Pod::Spec.new do |s|
  s.name             = 'CJCarouselView'
  s.version          = '0.1.3'
  s.summary          = 'A Carousel View In Objective-C'
  s.description      = <<-DESC
UITableView Style API.
Not Other Lib Dependency.
Support Customize Each Single Page.
Support Infinity Looping Scroll.
Support Horizontal An Vertical Direction.
Support Fade Transition.
                       DESC

  s.homepage         = 'https://github.com/cj1024/CJCarouselView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'cj1024' => 'jianchen1024@gmail.com' }
  s.source           = { :git => 'https://github.com/cj1024/CJCarouselView.git', :tag => s.version.to_s }
  s.screenshots      = 'https://ftp.bmp.ovh/imgs/2020/12/68011dc7fba03ec0.gif'

  s.ios.deployment_target = '8.0'

  s.subspec 'Core' do |core|
    core.frameworks = 'UIKit'
    core.source_files = 'CJCarouselView/Classes/Core/**/*'
    core.public_header_files = 'CJCarouselView/Classes/Core/*.h'
    core.private_header_files = 'CJCarouselView/Classes/Core/Private/*.h'
  end

  s.default_subspecs = 'Core'

end
