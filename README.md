# ar-enum

[![Tests](https://github.com/fnando/ar-enum/workflows/Tests/badge.svg)](https://github.com/fnando/ar-enum)
[![Gem](https://img.shields.io/gem/v/ar-enum.svg)](https://rubygems.org/gems/ar-enum)
[![Gem](https://img.shields.io/gem/dt/ar-enum.svg)](https://rubygems.org/gems/ar-enum)

Add support for creating `ENUM` types in PostgreSQL with ActiveRecord. This gem
is no longer required for Rails 7.0+.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "ar-enum"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ar-enum

## Usage

### Creating enums

To create a `enum` type, use the method `create_enum`.

```ruby
# The type is created independently from the table.
create_enum :article_status, %w[draft published]

create_table :articles do |t|
  # Use the type `article_status` when defining your column.
  t.column :status, :article_status, null: false, default: "draft"
end
```

You can even use the type shortcut if you want; i.e. you can use
`t.article_status` instead of `t.column`.

```ruby
# The type is created independently from the table.
create_enum :article_status, %w[draft published]

create_table :articles do |t|
  # Use the type `article_status` when defining your column.
  t.article_status :status, null: false, default: "draft"
end
```

### Dropping enums

To remove the enum, use `drop_enum`.

```ruby
drop_enum :article_status
```

You'll receive a `ActiveRecord::StatementInvalid` if any of your tables have a
dependency on the type; i.e. you're have a column using that enum. You can drop
these columns by specifying `cascade: true`.

```ruby
drop_enum :article_status, cascade: true
```

If you don't want to remove the column, change the column type before dropping
the enum.

```ruby
change_column :articles, :status, :text
drop_enum :article_status
```

### Adding new labels

Use `add_enum_label` to add new values to the enum type. You can control where
the value will be inserted by using `before: label` and `after: label`.

```ruby
create_enum :article_status, %w[draft published]

# labels will be sorted as [draft, published, unlisted]
add_enum_label :article_status, "unlisted"

# labels will be sorted as [draft, unlisted, published]
add_enum_value :article_status, "unlisted", after: "draft"

# labels will be sorted as [draft, unlisted, published]
add_enum_value :article_status, "unlisted", before: "published"
```

**WARNING:** PostgreSQL does not have a way of removing values from enum types.

### Renaming existing labels

Use `rename_enum_label` to rename a value.

```ruby
create_enum :article_status, %w[draft unlisted published]

# labels will be [draft, unlisted, live]
rename_enum_label :article_status, "published", "live"
```

### Reversing changes

The following commands can be reversed:

- `create_enum`
- `rename_enum_label`

```ruby
class CreateColorEnumClass < ActiveRecord::Migration
  def change
    create_enum :color, %w[red blue black]
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`rake test` to run the tests. You can also run `bin/console` for an interactive
prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/fnando/ar-enum. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
