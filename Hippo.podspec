Pod::Spec.new do |s|
    s.name         = 'Hippo'
    s.version      = '1.7.24'
    s.summary      = 'Now add Agent in app for quick support.'
    s.homepage     = 'https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS'
    s.documentation_url = 'https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS'
    
    s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
        Licensed under the Apache License, Version 2.0 (the 'License');
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
    
    s.author             = { 'Vishaljhanjhri' => 'https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS.git' }
    
    s.source       = { :git => 'https://git.clicklabs.in/publicrepos/Hippo-SDK-iOS.git', :tag => s.version }
    s.ios.deployment_target = '9.0'
    s.source_files = 'Hippo/**/*.{swift,h,m}'
    s.exclude_files = 'Classes/Exclude'
    s.static_framework = false
    
    s.swift_version = '4.2'
    
    s.resource_bundles = {
        'Hippo' => ['Hippo/*.{lproj,storyboard,xcassets,gif}','Hippo/Assets/**/*.imageset','Hippo/UIView/TableViewCell/**/*.xib','Hippo/UIView/CollectionViewCells/**/*.xib','Hippo/UIView/CustomViews/**/*.xib', 'Hippo/**/*.gif', 'README.md']
    }
    s.resources = ['Hippo/*.xcassets']
    s.preserve_paths = ['README.md']
    
    s.dependency 'MZFayeClient'
    s.default_subspec = 'Chat'
   
    
    s.subspec 'Chat' do |chat|
        
    end
    
    s.subspec 'Call' do |callClient|
        s.pod_target_xcconfig = { "ENABLE_BITCODE" => "No" }
        callClient.dependency 'HippoCallClient', '0.0.6'
    end
    
end
