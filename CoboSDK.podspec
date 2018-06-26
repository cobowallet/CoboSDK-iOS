Pod::Spec.new do |s|  
    s.name              = 'CoboSDK'
    s.version           = '1.0'
    s.summary           = 'Dapp SDK to use with Cobo Wallet'
    s.homepage          = 'https://cobo.com/'

    s.author            = { 'Name' => 'xzhang@cobo.com' }
    s.license           = { "type": "Copyright", "text": "Copyright © 2018 Cobo. All rights reserved." }

    s.platform          = :ios
    s.source            = { :git => 'https://github.com/cobowallet/CoboSDK-iOS.git', :tag => s.version }
    s.source_files      = ''
    s.ios.deployment_target = '9.0'
    s.ios.vendored_frameworks = 'CoboSDK.framework'
    s.dependency 'web3swift', '~> 0.8.0'
end