group :specs, halt_on_fail: true do
  guard :rspec, cmd: "bundle exec rspec", failed_mode: :keep do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})                { |m| "spec/#{m[1]}_spec.rb" }
    watch("spec/spec_helper.rb")             { "spec" }
  end
end