Pod::Spec.new do |s|
  s.name            = 'DMStackCollections'
  s.author          = { "Dmitry Ponomarev" => "demdxx@gmail.com" }
  s.version         = '0.1.0'
  s.license         = 'MIT'
  s.homepage        = 'https://github.com/demdxx/DMStackCollections'
  s.source          = {
    :git => 'https://github.com/demdxx/DMStackCollections.git',
    :tag => 'v0.1.0'
  }
  
  s.source_files    = 'Classes/*.{m,h}'
  s.requires_arc    = true
  
  s.frameworks      = 'UIKit'
  s.dependency      'CPAnimationSequence',
                    :git => 'https://github.com/demdxx/CPAnimationSequence.git', #'~> 0.0.4',
                    :commit => '9183a7d5fd60e99548a0f3d27162ceb1417851c0'
end