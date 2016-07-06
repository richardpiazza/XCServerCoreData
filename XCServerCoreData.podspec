Pod::Spec.new do |s|
  s.name = "XCServerCoreData"
  s.version = "2.1.2"
  s.summary = "A Core Data framework that models the Xcode Server API entities."
  s.description = <<-DESC
  This framework models most of the Xcode Server REST API entities into a Core Data object graph.
                     DESC
  s.homepage = "https://github.com/richardpiazza/XCServerCoreData"
  s.license = 'MIT'
  s.author = { "Richard Piazza" => "github@richardpiazza.com" }
  s.social_media_url = 'https://twitter.com/richardpiazza'

  s.source = { :git => "https://github.com/richardpiazza/XCServerCoreData.git", :tag => s.version.to_s }
  s.source_files = 'Sources/*'
  s.resources = 'Resources/*'
  s.platforms = { :ios => '9.1' }
  s.frameworks = 'Foundation', 'CoreData'
  s.requires_arc = true
  s.dependency 'CodeQuickKit/CoreData', '~> 2.5'
  s.dependency 'XCServerAPI', '~> 1.0'

end
