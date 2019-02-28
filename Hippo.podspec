#
#  Be sure to run `pod spec lint SDKDemo.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Hippo"
  s.version      = "2.0.0"
  s.summary      = "Ticket Support"
  s.homepage     = "https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS.git"

  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

  s.author             = { "vishaljhanjhri" => "https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS.git" }

  s.source       = { :git => "https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS.git", :tag => "2.0.0" }
  s.ios.deployment_target = "8.0"
  s.source_files = "Fugu/**/*.swift"
  s.exclude_files = "Classes/Exclude"
  
  s.resource_bundles = {
    "Hippo" => ["Fugu/*.{lproj,storyboard,xcassets,gif}","Fugu/Assets/**/*.imageset","Fugu/UIView/TableViewCell/**/*.xib","Fugu/**/*.gif"]
  }
  s.resources = ["Fugu/*.xcassets"]
  s.dependency "MZFayeClient"
  s.dependency 'XLPagerTabStrip', '~> 8.0'

end
