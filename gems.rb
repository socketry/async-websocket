source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"

	gem "bake-test"
	gem "bake-test-external"
	
	gem "utopia-project"
end
