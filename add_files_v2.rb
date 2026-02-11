require 'xcodeproj'

project_path = 'MasonryDemo.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Find the MasonryDemo group
# Based on inspection, the main group has a child named "MasonryDemo"
masonry_demo_group = project.main_group['MasonryDemo']

unless masonry_demo_group
  puts "Error: Could not find 'MasonryDemo' group"
  exit 1
end

# Helper to find or create group path
def find_or_create_group(parent_group, path_components)
  current_group = parent_group
  path_components.each do |name|
    # Check if child exists
    found = current_group.children.find { |child| child.isa == 'PBXGroup' && child.name == name }
    if found
      current_group = found
    else
      current_group = current_group.new_group(name)
    end
  end
  current_group
end

# Add DSToast.swift
# Path: MasonryDemo/Core/DesignSystem/Components/DSToast.swift
components_group = find_or_create_group(masonry_demo_group, ['Core', 'DesignSystem', 'Components'])
# The file is in MasonryDemo/Core/DesignSystem/Components/DSToast.swift
# But the group structure mimics the file system.
# We should verify if the file reference already exists to avoid duplicates
existing_ref = components_group.files.find { |f| f.path.include?('DSToast.swift') }
if existing_ref
  puts "DSToast.swift already exists"
else
  # Use full relative path from project root
  file_path = 'MasonryDemo/Core/DesignSystem/Components/DSToast.swift'
  ref = components_group.new_reference(file_path)
  target.add_file_references([ref])
  puts "Added DSToast.swift"
end

# Add DSComplexListViewController.swift
# Path: MasonryDemo/Demos/BasicKnowledge/DesignSystem/DSComplexListViewController.swift
ds_demo_group = find_or_create_group(masonry_demo_group, ['Demos', 'BasicKnowledge', 'DesignSystem'])
existing_ref = ds_demo_group.files.find { |f| f.path.include?('DSComplexListViewController.swift') }
if existing_ref
  puts "DSComplexListViewController.swift already exists"
else
  file_path = 'MasonryDemo/Demos/BasicKnowledge/DesignSystem/DSComplexListViewController.swift'
  ref = ds_demo_group.new_reference(file_path)
  target.add_file_references([ref])
  puts "Added DSComplexListViewController.swift"
end

project.save
