# Icd::Api

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/icd/api`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'icd-api'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install icd-api

## Usage

### Search medical condition
`client_api.search(term)`

### Get infos from entity_id
`fetch_info_by_stem_id(entity_id)`

### Get stem_id from medical condition code
`fetch_stem_id_by_code(code)`

### Get parent entity_id from medical condition code
`fetch_parent_stem_by_code(code)`

### Get toplevel category from medical condition code
`fetch_toplevel_category_by_code(code)`
### 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

