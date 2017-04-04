Pod::Spec.new do |spec|

    spec.name                   = 'Swift.Json'
    spec.version                = '1.1.3'
    spec.summary                = 'Json auto-[parser/writer] for Swift 3.'

    spec.homepage               = 'https://github.com/andersonlucasg3/Swift.Json'
    spec.license                = { :type => 'MIT' }
    spec.authors                = { 'Anderson Lucas C. Ramos' => 'andersonlucas3d@gmail.com' }
    spec.source                 = { :git => 'https://github.com/andersonlucasg3/Swift.Json.git', :tag => spec.version.to_s }

    spec.platform               = 'ios'
    spec.ios.deployment_target  = '8.0'

    spec.source_files           = 'Swift.Json/*.swift'

end
