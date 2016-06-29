Pod::Spec.new do |s|
  s.name = "XCServerCoreData"
  s.version = "2.0.1"
  s.summary = "Bringing Xcode Server and Core Data together."
  s.description = <<-DESC
  An Apple library that models an Xcode Server into Core Data
                     DESC
  s.homepage = "https://github.com/richardpiazza/XCServerCoreData"
  s.license = 'MIT'
  s.author = { "Richard Piazza" => "github@richardpiazza.com" }
  s.social_media_url = 'https://twitter.com/richardpiazza'

  s.source = { :git => "https://github.com/richardpiazza/XCServerCoreData.git", :tag => s.version.to_s }
  s.source_files = 'Sources/*'
  s.resources = 'Resources/*'
  s.platforms = { :ios => '9.1', :tvos => '9.0' }
  s.frameworks = 'Foundation', 'CoreData'
  s.requires_arc = true
  s.dependency 'CodeQuickKit/CoreData', '~> 2.5'

end
