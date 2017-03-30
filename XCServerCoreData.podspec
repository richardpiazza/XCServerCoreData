Pod::Spec.new do |s|
  s.name = "XCServerCoreData"
  s.version = "3.2.0"
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
  s.dependency 'CodeQuickKit/CoreData', '~> 4.2'
  s.dependency 'XCServerAPI', '~> 2.2'

  s.osx.deployment_target = "10.12"
  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"
  s.watchos.deployment_target = "3.0"
end
