Pod::Spec.new do |s|
  s.name         = 'Hippo'
  s.version      = '2.1.71'
  s.summary      = 'Now add Agent in app for quick support.'
  s.homepage     = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
  s.documentation_url = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'

  s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
  s.author       = { 'Vishal Jhanjhri' => 'jhanjhri.vishal@gmail.com' }

  s.source       = { :git => 'https://github.com/Jungle-Works/Hippo-iOS-SDK.git', :tag => s.version }

  s.ios.deployment_target = '15.1'
  s.swift_version = '5.0'

  # Framework should be static (correct)
  s.static_framework = true

  # Only code files
  s.source_files = 'Hippo/**/*.{swift,h,m}'

  # All resources in a single well-structured bundle
  s.resource_bundles = {
    'Hippo' => [
      'Hippo/**/*.{storyboard,xib,xcassets,strings,gif,wav,js}',
      'Hippo/**/*.lproj'
    ]
  }

  # REMOVE resources section — it causes duplicate bundles
  # s.resources = ['Hippo/*.xcassets']

  s.dependency 'Socket.IO-Client-Swift'
  s.default_subspec = 'Chat'

  s.subspec 'Chat' do |chat|
  end

  s.subspec 'Call' do |callClient|
    callClient.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }
    callClient.dependency 'HippoCallClient'
  end
end
