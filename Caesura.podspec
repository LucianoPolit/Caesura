Pod::Spec.new do |s|

  s.name             = 'Caesura'
  s.version          = '1.0.0-beta.1'
  s.summary          = 'Modularization Library - Powered by ReSwift'
  s.description      = <<-DESC
                          Unidirectional Data Flow
                          Navigation Router
                          Time Travel
                          Crash Tracking
                          Session Injection
                          ReRxSwift Integration
                          DESC
  s.homepage         = 'https://github.com/LucianoPolit/Caesura'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Luciano Polit' => 'lucianopolit@gmail.com' }
  s.source           = { :git => 'https://github.com/LucianoPolit/Caesura.git', :tag => s.version.to_s }
  s.platform         = :ios, '10.0'
  s.swift_version    = '5.0'

  s.subspec 'Core' do |ss|
    ss.source_files  = 'Source/Core/**/*.swift'
    ss.dependency      'ReSwift', '~> 5.0'
    ss.dependency      'Then', '~> 2.7'
  end

  s.subspec 'UI' do |ss|
    ss.source_files  = 'Source/UI/**/*.swift'
    ss.dependency      'Caesura/Core'
  end

  s.subspec 'StandardAction' do |ss|
    ss.source_files  = 'Source/StandardAction/**/*.swift'
    ss.dependency      'Caesura/Core'
  end

  s.subspec 'Middlewares' do |ss|
    ss.subspec 'General' do |sss|
      sss.source_files  = 'Source/Middlewares/**/*.swift'
      sss.exclude_files = 'Source/Middlewares/Debug/**/*.swift'
      sss.dependency      'Caesura/Core'
      sss.dependency      'Caesura/StandardAction'
    end

    ss.subspec 'Debug' do |sss|
      sss.source_files  = 'Source/Middlewares/Debug/**/*.swift'
      sss.dependency      'Caesura/Core'
      sss.dependency      'Caesura/StandardAction'
    end
  end

  s.subspec 'ReRxSwift' do |ss|
    ss.source_files  = 'Source/ReRxSwift/**/*.swift'
    ss.dependency      'ReRxSwift', '~> 2.2'
    ss.dependency      'Caesura/Core'
  end

end
