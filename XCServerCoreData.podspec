Pod::Spec.new do |s|
  s.name = "XCServerCoreData"
  s.version = "5.2.1"
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
  s.frameworks = 'Foundation', 'CoreData'
  s.requires_arc = true
  s.dependency 'CodeQuickKit', '~> 6.0'
  s.dependency 'XCServerAPI', '~> 4.0'

  s.osx.deployment_target = "10.13"
  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "11.0"
  s.watchos.deployment_target = "4.0"
end
