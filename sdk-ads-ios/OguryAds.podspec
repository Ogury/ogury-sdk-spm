Pod::Spec.new do |spec|
  spec.name         = 'OguryAds'
  spec.version      = '3.6.0'
  spec.summary      = 'Description courte du pod.'
  spec.authors      = 'Ogury'
  spec.description  = 'Description détaillée du pod.'
  spec.homepage     = 'https://lien.vers.votre.pod'
  spec.source       = { :git => '' }
  spec.source_files = 'Sources/**/*.{h,m,swift}'
  spec.dependency 'OguryCore'
  spec.static_framework = true
  spec.ios.vendored_frameworks = 'OMSDK_Ogury.xcframework'
end
