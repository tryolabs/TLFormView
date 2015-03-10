#
# Be sure to run `pod lib lint TLFormView.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "TLFormView"
  s.version          = "0.0.1"
  s.summary          = "An universal iOS form"
  s.homepage         = "https://github.com/tryolabs/TLFormView"
  s.license          = 'MIT'
  s.author           = { "BrunoBerisso" => "bruno@tryolabs.com" }
  s.source           = { :git => "https://github.com/tryolabs/TLFormView.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
end
