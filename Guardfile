rspec_options = {
  :all_after_pass => false,
  :all_on_start   => false,
}

guard 'rspec', rspec_options do
  watch(%r{^spec/.+_spec\.rb$}) { "spec" }
  watch(%r{^lib/(.+)\.rb$}) { "spec" }
  watch('spec/helper.rb') { "spec" }
  watch(%r{lib/adapter/spec/(.+)\.rb}) { "spec" }
end

guard 'bundler' do
  watch('Gemfile')
  watch(/^.+\.gemspec/)
end
