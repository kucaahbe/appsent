When /^I add file named "([^"]*)"$/ do |filename|
  When %{an empty file named "#{filename}"}
end

When /^I write to "([^"]*)" following:$/ do |filename, content|
  When %{a filenamed "#{filename}" with:}, content
end
