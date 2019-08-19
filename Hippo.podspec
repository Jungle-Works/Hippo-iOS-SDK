Pod::Spec.new do |s|
    s.name         = 'Hippo'
    s.version      = '1.7.44'
    s.summary      = 'Now add Agent in app for quick support.'
    s.homepage     = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
    s.documentation_url = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
    
    s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
    
    s.author             = { 'Vishal Jhanjhri' => 'jhanjhri.vishal@gmail.com' }
    
    s.source       = { :git => 'https://github.com/Jungle-Works/Hippo-iOS-SDK.git', :tag => s.version }
    s.ios.deployment_target = '9.0'

    
    
    s.default_subspec = 'Chat'

    s.subspec 'Chat' do |chat|
      s.ios.vendored_frameworks = 'Hippo.framework'
      chat.preserve_paths = ['Hippo.framework']
    end
    
    s.subspec 'Call' do |callClient|
      s.pod_target_xcconfig = { "ENABLE_BITCODE" => "No" }
      callClient.preserve_paths = ['*.framework']
      callClient.dependency 'Hippo/Chat'
      callClient.dependency 'Hippo/RTC'
    end
    
    
    
    s.subspec 'RTC' do |rtc|
      rtc.ios.vendored_frameworks = 'WebRTC.framework', 'Hippo.framework'
      rtc.preserve_paths = ['*.framework']
      end

    
end
