# HyperNavigator

A RESTful resource client that fetches documents following a given path.

It expects each resource to return a structure in the given format:

```JSON
{
  "links": [
    {
      "rel": "apple",
      "href": "/path/to/apple"
    },
    {
      "rel": "banana",
      "href": "/path/to/banana"
    }
  ]
}

The main entry point for this gem is

```ruby
  HyperNavigator.surf(url, traversal-path)
```

The `traversal-path` argument provided is an array of `rel` names.  This array should contain the rel names in order of traversal.

An example path, that will look for an `apple` rel in the resource, fetch from it's corresponding href, then look for a `pudding` rel in that resource and fetch its corresponding href:

```ruby
  traversal-path = ["apple", "pudding"]

  HyperNavigator.surf("https://fruitful-resources.io", traversal-path)
```

The return value of `#surf` will be a `HyperNavigator::Node`.

Some useful attributes of `HyperNavigator::Node` are:

- `response`, what the HTTP service returned
- `rel`, the rel name for the resource that fetched this document
- `href`, the href the resource was fetched from

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hyper_navigator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hyper_navigator

## Usage

`#surf` will return all nodes encountered during a browse.
`#surf_to_leaves` will return just the leaf nodes during a browse.

Example usage:

```ruby
  require 'hyper_navigator'

  path = ["apple", "pudding"]
  headers = { "Authorization": "Bearer #{$token}" }

  result = HyperNavigator.surf_to_leaves('https://fruitful-resources.io', path, headers)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/carld/hyper_navigator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the HyperNavigator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/carld/hyper_navigator/blob/master/CODE_OF_CONDUCT.md).
