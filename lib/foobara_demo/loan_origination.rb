require "foobara/all"

module FoobaraDemo
  foobara_organization!

  module LoanOrigination
    foobara_domain!
  end
end

Foobara::Util.require_directory "#{__dir__}/../../src/types"
Foobara::Util.require_pattern "#{__dir__}/../../src/*.rb"
Foobara::Util.require_directory "#{__dir__}/../../src"
