# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mixpanel_mail/version"

Gem::Specification.new do |s|
  s.name        = "mixpanel-mail"
  s.version     = Mixpanel::Mail::VERSION
  s.authors     = ["Michael Rykov"]
  s.email       = ["mrykov@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{TODO: Write a gem summary}
  s.description = %q{TODO: Write a gem description}

  s.rubyforge_project = "mixpanel-mail"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Runtime depencendies
  s.add_runtime_dependency "multi_json"

  # Development dependencies
  # See Gemfile
end
