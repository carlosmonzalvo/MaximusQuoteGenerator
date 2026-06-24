#!/usr/bin/env ruby
# Adds the client/vehicle expediente feature files to the app target, and
# re-syncs the unit-test target sources. Idempotent.
#
#   ruby scripts/add_records_feature.rb
#
require 'xcodeproj'

PROJECT_PATH = File.expand_path('../MaximusPrecision.xcodeproj', __dir__)
ROOT         = File.dirname(PROJECT_PATH)
APP_TARGET   = 'MaximusPrecision'
UNIT_NAME    = 'MaximusPrecisionTests'

project = Xcodeproj::Project.open(PROJECT_PATH)
app = project.targets.find { |t| t.name == APP_TARGET } or raise "no app target"

# Relative paths of new app-target sources.
app_files = %w[
  MaximusPrecision/App/RootTabView.swift
  MaximusPrecision/Records/ClientRecord.swift
  MaximusPrecision/Records/VehicleRecord.swift
  MaximusPrecision/Records/ServiceRecord.swift
  MaximusPrecision/Records/ClientVehicleRepository.swift
  MaximusPrecision/Features/Records/ViewModels/RecordsViewModel.swift
  MaximusPrecision/Features/Records/Views/RecordsView.swift
  MaximusPrecision/Features/Records/Views/RecordEditSheet.swift
  MaximusPrecision/Features/Records/Views/VehicleDetailView.swift
]

existing_paths = app.source_build_phase.files.map { |f| f.file_ref&.real_path&.to_s }.compact

app_files.each do |rel|
  abs = File.expand_path(rel, ROOT)
  next if existing_paths.include?(abs)
  # Place the reference in a group mirroring its directory.
  group = project.main_group.find_subpath(File.dirname(rel), true)
  group.set_source_tree('SOURCE_ROOT') if group.source_tree.nil?
  ref = group.new_reference(abs)
  app.add_file_references([ref])
  puts "Added to #{APP_TARGET}: #{rel}"
end

# Re-sync unit-test sources via glob (matches add_unittests_target.rb behaviour).
unit = project.targets.find { |t| t.name == UNIT_NAME }
if unit
  test_files = Dir.chdir(ROOT) { Dir.glob("#{UNIT_NAME}/**/*.swift").sort }
  group = project.main_group.find_subpath(UNIT_NAME, true)
  already = unit.source_build_phase.files_references
  added = 0
  test_files.each do |rel|
    abs = File.expand_path(rel, ROOT)
    next if already.any? { |r| r.real_path.to_s == abs }
    ref = group.new_reference(abs)
    unit.add_file_references([ref])
    added += 1
    puts "Added to #{UNIT_NAME}: #{rel}"
  end
  puts "Unit test sources synced (+#{added})"
end

project.save
puts "Saved #{PROJECT_PATH}"
