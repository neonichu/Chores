Pod::Spec.new do |s|
  s.name         = 'Chores'
  s.version      = '0.0.1'
  s.summary      = 'A library for simplifying task execution in Swift.'
  s.homepage     = 'https://github.com/neonichu/Chores'
  s.license      = 'MIT'

  s.author             = { 'Boris Bügling' => 'boris@buegling.com' }
  s.social_media_url   = 'http://twitter.com/NeoNacho'

  s.platform     = :osx, '10.9'
  s.source       = { :git => 'https://github.com/neonichu/Chores.git',
                     :tag => s.version }
  s.source_files = 'Code'
end
