platform :ios, '12.0'

target 'Mojey' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods EmojiOne
  pod 'BigInt', :inhibit_warnings => true
  pod 'GRKOpenSSLFramework', '~> 1.0'

end


target 'MojeyMessage' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods EmojiOne
  pod 'BigInt', :inhibit_warnings => true
  pod 'GRKOpenSSLFramework', '~> 1.0'

end

post_install do |installer|
  installer.aggregate_targets.each do |aggregate_target|
    aggregate_target.xcconfigs.each do |config_name, config_file|
        config_file.attributes['OTHER_SWIFT_FLAGS'] = '$(inherited) "-D" "COCOAPODS"' if config_file.attributes['OTHER_SWIFT_FLAGS']
        xcconfig_path = aggregate_target.xcconfig_path(config_name)
        config_file.save_as(xcconfig_path)
    end
  end
end


