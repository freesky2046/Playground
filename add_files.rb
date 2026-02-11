require 'xcodeproj'

project_path = 'MasonryDemo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target_name = 'MasonryDemo'
target = project.targets.find { |t| t.name == target_name }

if target.nil?
  puts "Error: Target #{target_name} not found"
  exit 1
end

# Files to add
files = [
  {
    path: 'MasonryDemo/Core/DesignSystem/Components/DSToast.swift',
    group_path: ['MasonryDemo', 'Core', 'DesignSystem', 'Components']
  },
  {
    path: 'MasonryDemo/Demos/BasicKnowledge/DesignSystem/DSComplexListViewController.swift',
    group_path: ['MasonryDemo', 'Demos', 'BasicKnowledge', 'DesignSystem']
  }
]

files.each do |file|
  path = file[:path]
  group_names = file[:group_path]
  
  # Find or create group hierarchy
  current_group = project.main_group
  group_names.each do |name|
    next_group = current_group[name]
    if next_group.nil?
      puts "Creating group: #{name} in #{current_group.display_name}"
      next_group = current_group.new_group(name)
    end
    current_group = next_group
  end
  
  # Check if file already exists in group
  if current_group.find_file_by_path(File.basename(path))
    puts "File #{path} already exists in project, skipping."
  else
    puts "Adding #{path} to project..."
    file_ref = current_group.new_reference(path)
    target.add_file_references([file_ref])
  end
end

project.save
puts "Project saved."
