Pod::Spec.new do |s|
  s.name         = 'Hippo'
  
  s.version      = '2.1.65'
  
  s.summary      = 'Now add Agent in app for quick support.'
  s.homepage     = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
  s.documentation_url = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
  
  s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
  
  s.author             = { 'Vishal Jhanjhri' => 'jhanjhri.vishal@gmail.com' }
  
  s.source       = { :git => 'https://github.com/Jungle-Works/Hippo-iOS-SDK.git', :tag => s.version }
  s.ios.deployment_target = '12.0'
  s.source_files = 'Hippo/**/*.{swift,h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.static_framework = false
  
  s.swift_version = '4.2'
  
  s.resource_bundles = {
    
    'Hippo' => ['Hippo/*.{lproj,storyboard,xcassets,gif}','Hippo/Assets/**/*.imageset','Hippo/UIView/TableViewCell/**/*.xib','Hippo/UIView/CollectionViewCells/**/*.xib','Hippo/UIView/CustomViews/**/*.xib','Hippo/InternalClasses/Views/**/*.xib','Hippo/InternalClasses/Module/**/*.xib', 'Hippo/**/*.gif','Hippo/**/*.wav','Hippo/Language/**/*.strings', 'Hippo/**/*.js','README.md']
    
  }
  
  s.resources = ['Hippo/*.xcassets']
  
  s.dependency 'Socket.IO-Client-Swift'
  s.dependency 'CropViewController'
  s.dependency 'DropDown'
  
  s.default_subspec = 'Chat'
  
  s.pod_target_xcconfig = {
    "EXCLUDED_ARCHS[sdk=iphonesimulator*]" => "arm64"
  }
  
  s.subspec 'Chat' do |chat|
    
  end
  
  s.subspec 'Call' do |callClient|
    s.pod_target_xcconfig = { "ENABLE_BITCODE" => "No" }
    callClient.dependency 'HippoCallClient'
  end
end
