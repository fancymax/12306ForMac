Pod::Spec.new do |s|
  s.platform              = :osx
  s.name                  = "MASPreferences"
  s.version               = "1.1.4"
  s.summary               = "Modern implementation of the Preferences window for OS X apps, used in TextMate, GitBox and Mou."
  s.homepage              = "https://github.com/shpakovski/MASPreferences"
  s.license               = { :type => 'BSD', :file => 'LICENSE.md' }
  s.author                = { "Vadim Shpakovski" => "vadim@shpakovski.com" }
  s.source                = { :git => 'https://github.com/shpakovski/MASPreferences.git', :tag => '1.1.4' }
  s.source_files          = 'Framework/*.{h,m}'
  s.resources             = 'Framework/en.lproj/*.xib'
  s.exclude_files         = 'README.md', 'LICENSE.md', 'MASPreferences.podspec'
  s.requires_arc          = false
end
