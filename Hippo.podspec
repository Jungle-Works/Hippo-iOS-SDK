Pod::Spec.new do |s|
    s.name         = 'Hippo'
    s.version      = '2.2.0'
    s.summary      = 'Now add Agent in app for quick support.'
    s.homepage     = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'
    s.documentation_url = 'https://github.com/Jungle-Works/Hippo-iOS-SDK'

    s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }

    s.author       = { 'Neha Vaish' => 'neha.vaish@jungleworks.com' }

    s.source       = { :git => 'https://github.com/Jungle-Works/Hippo-iOS-SDK.git', :tag => s.version }
    s.source_files = 'Hippo/**/*.{swift,h,m}'
    s.exclude_files = 'Classes/Exclude'

    # Dynamic: VideoSDKRTC (via the Call subspec) ships dynamic frameworks.
    s.static_framework = false

    s.ios.deployment_target = '15.6'
    s.swift_version = '5.9'

    # Recursive globs (from master) so new xibs/assets in any folder are bundled.
    s.resource_bundles = {
        'Hippo' => [
            'Hippo/**/*.{storyboard,xib,xcassets,strings,gif,wav,js}',
            'Hippo/**/*.lproj',
            'README.md'
        ]
    }

    s.resources = ['Hippo/*.xcassets']

    # Socket.IO-Client-Swift is supplied transitively by VideoSDKRTC (pinned = 16.1.1);
    # declaring it here clashes with that pin.
#    s.dependency 'Socket.IO-Client-Swift', '~> 16.1.1'
    s.dependency 'CropViewController'
    s.dependency 'DropDown'

    s.default_subspec = 'Chat'

    s.subspec 'Chat' do |chat|
    end

    s.subspec 'Call' do |callClient|
        callClient.pod_target_xcconfig = { "ENABLE_BITCODE" => "NO" }
        callClient.dependency 'HippoCallClient'
    end
end
