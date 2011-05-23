When /^I add file named "([^"]*)"$/ do |filename|
  When %{an empty file named "#{filename}"}
end

When /^I write to "([^"]*)" following:$/ do |filename, content|
  When %{a file named "#{filename}" with:}, content
end

Then /^the output should contain following appsent error:$/ do |string|
  Then "the output should contain:", "failed to load some configuration files (AppSent::Error)\n"+string
end
