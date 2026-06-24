#!/usr/bin/env ruby
# Adds the MaximusPrecisionUITests target (Robot-pattern XCUITest infra) to the
# project. Idempotent: safe to re-run; it skips work already done.
#
#   ruby scripts/add_uitests_target.rb
#
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../MaximusPrecision.xcodeproj', __dir__)
APP_TARGET   = 'MaximusPrecision'
UITEST_NAME  = 'MaximusPrecisionUITests'
DEPLOYMENT   = '17.0'
TEAM         = 'YFJ48SR2KW'

project = Xcodeproj::Project.open(PROJECT_PATH)
app_target = project.targets.find { |t| t.name == APP_TARGET }
raise "App target #{APP_TARGET} not found" unless app_target

# --- 1. Shared accessibility identifiers file (app + tests) -------------------
shared_rel = 'MaximusPrecision/Support/AccessibilityIdentifiers.swift'
support_group = project.main_group.find_subpath('MaximusPrecision/Support', true)
support_group.set_source_tree('SOURCE_ROOT')
shared_ref = support_group.files.find { |f| f.real_path.to_s.end_with?('AccessibilityIdentifiers.swift') }
shared_ref ||= support_group.new_reference(shared_rel)
unless app_target.source_build_phase.files_references.include?(shared_ref)
  app_target.add_file_references([shared_ref])
  puts "Added #{shared_rel} to #{APP_TARGET}"
end

# --- 2. UI test target -------------------------------------------------------
uitest_target = project.targets.find { |t| t.name == UITEST_NAME }
if uitest_target.nil?
  uitest_target = project.new_target(:ui_test_bundle, UITEST_NAME, :ios, DEPLOYMENT)
  puts "Created target #{UITEST_NAME}"
end

# Build settings to match the app target.
uitest_target.build_configurations.each do |config|
  s = config.build_settings
  s['PRODUCT_NAME'] = '$(TARGET_NAME)'
  s['PRODUCT_BUNDLE_IDENTIFIER'] = 'com.maximusprecision.app.uitests'
  s['IPHONEOS_DEPLOYMENT_TARGET'] = DEPLOYMENT
  s['SWIFT_VERSION'] = '5.0'
  s['GENERATE_INFOPLIST_FILE'] = 'YES'
  s['CODE_SIGN_STYLE'] = 'Automatic'
  s['DEVELOPMENT_TEAM'] = TEAM
  s['TEST_TARGET_NAME'] = APP_TARGET
  s['TARGETED_DEVICE_FAMILY'] = '1,2'
  s['CURRENT_PROJECT_VERSION'] = '1'
  s['MARKETING_VERSION'] = '1.0'
end

# Depend on the app target so it builds + installs before the tests run.
uitest_target.add_dependency(app_target) unless uitest_target.dependencies.any? { |d| d.target == app_target }

# --- 3. Test source files ----------------------------------------------------
test_files = Dir.chdir(File.dirname(PROJECT_PATH)) do
  Dir.glob("#{UITEST_NAME}/**/*.swift").sort
end
uitest_group = project.main_group.find_subpath(UITEST_NAME, true)
uitest_group.set_source_tree('SOURCE_ROOT')
uitest_group.clear

test_refs = test_files.map { |rel| uitest_group.new_reference(rel) }
# The shared identifiers file is compiled into the test bundle too.
already = uitest_target.source_build_phase.files_references
(test_refs + [shared_ref]).each do |ref|
  uitest_target.add_file_references([ref]) unless already.include?(ref)
end
puts "Test bundle sources: #{test_files.size} test files + shared identifiers"

# --- 4. Shared scheme with the test action -----------------------------------
scheme_path = Xcodeproj::XCScheme.shared_data_dir(PROJECT_PATH)
scheme_file = File.join(scheme_path, "#{APP_TARGET}.xcscheme")
scheme = File.exist?(scheme_file) ? Xcodeproj::XCScheme.new(scheme_file) : Xcodeproj::XCScheme.new
scheme.configure_with_targets(app_target, uitest_target) unless File.exist?(scheme_file)
unless scheme.test_action.testables.any? { |t| t.buildable_references.any? { |b| b.target_name == UITEST_NAME } }
  testable = Xcodeproj::XCScheme::TestAction::TestableReference.new(uitest_target)
  scheme.test_action.add_testable(testable)
end
# xcodeproj can drop the launch runnable when re-saving an existing scheme,
# which leaves Run/Profile with "nothing to launch" (sim won't start). Always
# pin the app as the runnable.
scheme.launch_action.buildable_product_runnable =
  Xcodeproj::XCScheme::BuildableProductRunnable.new(app_target)
scheme.profile_action.buildable_product_runnable =
  Xcodeproj::XCScheme::BuildableProductRunnable.new(app_target)
scheme.save_as(PROJECT_PATH, APP_TARGET, true)
puts "Shared scheme updated: #{APP_TARGET}.xcscheme"

project.save
puts "Saved #{PROJECT_PATH}"
