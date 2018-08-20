# SimpleBigtableClient

Simple abstraction on top of https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-bigtable

Which is at the time of writing currently under alpha

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_bigtable_client'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_bigtable_client

## Usage

The main point of this gem is to simplify the interfaces when reading and writing to bigtable

### Reading

Turns this
```ruby
require 'google/cloud/bigtable/v2'
bigtable_client = Google::Cloud::Bigtable::V2.new
formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("project", "instance", "table")
bigtable_client.read_rows(formatted_table_name).each do |cell_chunk|
  cell_chunk # => <Google::Bigtable::V2::ReadRowsResponse: chunks: [<Google::Bigtable::V2::ReadRowsResponse::CellChunk: row_key:....
end
```

Into
```ruby
require 'simple_bigtable_client'
client = SimpleBigTableClient.new('instance') # Uses ENV['GOOGLE_CLOUD_PROJECT']
client.read_rows do |row|
  row #=> {_row_key: 'a', b: 'c'}
end
```

### Writing

Turns

```ruby
require 'google/cloud/bigtable/v2'
bigtable_client = Google::Cloud::Bigtable::V2.new
formatted_table_name = Google::Cloud::Bigtable::V2::BigtableClient.table_path("project", "instance", "table")
entries = [
  {
    row_key: 'test',
    mutations: [
      {
        set_cell: {
          column_qualifier: 'a',
          family_name: 'cf_v1',
          value: 'value'
        }
      },
      {
        set_cell: {
          column_qualifier: 'b',
          family_name: 'cf_v1',
          value: 'value2'
        }
      }
    ]
  },
  {
    row_key: 'test2',
    mutations: [
      {
        set_cell: {
          column_qualifier: 'a',
          family_name: 'cf_v1',
          value: 'value'
        }
      },
      {
        set_cell: {
          column_qualifier: 'b',
          family_name: 'cf_v1',
          value: 'value2'
        }
      }
    ]
  }
]
bigtable_client.mutate_rows(formatted_table_name, entries).each do |result|
  p result
end
```

Into

```ruby
require 'simple_bigtable_client'
client = SimpleBigTableClient.new('instance') # Uses ENV['GOOGLE_CLOUD_PROJECT']
entries = {
  first: {a: 'b', c: 'd'},
  second: {e: 'f'},
}
subject.mutate_rows('table', 'column_family', entries) do |result|
  p result
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Fonsan/simple_bigtable_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SimpleBigtableClient project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/Fonsan/simple_bigtable_client/blob/master/CODE_OF_CONDUCT.md).
