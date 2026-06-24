#!/usr/bin/env ruby
# Adds the MaximusPrecisionTests unit-test target (hosted in the app so it can
# `@testable import MaximusPrecision`). Idempotent.
#
#   ruby scripts/add_unittests_target.rb
#
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../MaximusPrecision.xcodeproj', __dir__)
APP_TARGET   = 'MaximusPrecision'
UNIT_NAME    = 'MaximusPrecisionTests'
DEPLOYMENT   = '17.0'
TEAM         = 'YFJ48SR2KW'

project = Xcodeproj::Project.open(PROJECT_PATH)
app_target = project.targets.find { |t| t.name == APP_TARGET }
raise "App target #{APP_TARGET} not found" unless app_target

unit_target = project.targets.find { |t| t.name == UNIT_NAME }
if unit_target.nil?
  unit_target = project.new_target(:unit_test_bundle, UNIT_NAME, :ios, DEPLOYMENT)
  puts "Created target #{UNIT_NAME}"
end

unit_target.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.maximusprecision.app.tests'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT
  s['SWIFT_VERSION'] = '5.0'
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['DEVELOPMENT_TEAM'] = TEAM
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['MARKETING_VERSION'] = '1.0'
  s['TEST_HOST'] = '$(BUILT_PRODUCTS_DIR)/MaximusPrecision.app/MaximusPrecision'
  s['BUNDLE_LOADER'] = '$(TEST_HOST)'
end

unit_target.add_dependency(app_target) unless unit_target.dependencies.any? { |d| d.target == app_target }

# Test sources.
test_files = Dir.chdir(File.dirname(PROJECT_PATH)) do
  Dir.glob("#{UNIT_NAME}/**/*.swift").sort
end
group = project.main_group.find_subpath(UNIT_NAME, true)
group.clear
already = unit_target.source_build_phase.files_references
test_files.each do |rel|
  ref = group.new_reference(File.expand_path(rel, File.dirname(PROJECT_PATH)))
  unit_target.add_file_references([ref]) unless already.include?(ref)
end
puts "Unit test sources: #{test_files.size}"

# Add to the shared scheme's test action.
scheme_file = File.join(Xcodeproj::XCScheme.shared_data_dir(PROJECT_PATH), "#{APP_TARGET}.xcscheme")
if File.exist?(scheme_file)
  scheme = Xcodeproj::XCScheme.new(scheme_file)
  unless scheme.test_action.testables.any? { |t| t.buildable_references.any? { |b| b.target_name == UNIT_NAME } }
    scheme.test_action.add_testable(Xcodeproj::XCScheme::TestAction::TestableReference.new(unit_target))
    scheme.save_as(PROJECT_PATH, APP_TARGET, true)
    puts "Added #{UNIT_NAME} to scheme test action"
  end
end

project.save
puts "Saved #{PROJECT_PATH}"
