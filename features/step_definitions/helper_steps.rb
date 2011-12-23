When /^I add file named "([^"]*)"$/ do |filename|
  step %{an empty file named "#{filename}"}
end

When /^I write to "([^"]*)" following:$/ do |filename, content|
  step %{a file named "#{filename}" with:}, content
end
