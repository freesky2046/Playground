require 'xcodeproj'

project_path = 'MasonryDemo.xcodeproj'
project = Xcodeproj::Project.open(project_path)

puts "Main Group Class: #{project.main_group.class}"
puts "Main Group Children:"
project.main_group.children.each do |child|
  puts " - #{child.display_name} (#{child.class})"
end
