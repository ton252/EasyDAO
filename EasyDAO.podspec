
Pod::Spec.new do |s|
  s.name             = 'EasyDAO'
  s.version          = '0.1.5'
  s.summary          = 'Library implements dao pattern for Realm and Core Data for iOS'
  s.description      = <<-DESC
  This library allows you to implement the DAO pattern in the application
                       DESC
                       
  s.homepage         = 'https://github.com/ton252/EasyDAO'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ton252' => 'tonwork252@gmail.com' }
  s.source           = { :git => 'https://github.com/ton252/EasyDAO.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'EasyDAO/Classes/**/*'
  s.frameworks = 'CoreData', 'Foundation'
  s.dependency 'RealmSwift'
  
  # s.resource_bundles = {
  #   'EasyDAO' => ['EasyDAO/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
