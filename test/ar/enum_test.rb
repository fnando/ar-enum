# frozen_string_literal: true

require "test_helper"

class EnumTest < Minitest::Test
  include TestHelper

  setup do
    recreate_table
    Article.reset_column_information
  end

  def enum_labels(name)
    result = ActiveRecord::Base.connection.enum_types
    entry = result.find {|row| row["name"] == name.to_s }

    return [] unless entry

    entry["labels"].split(",")
  end

  test "adds enum" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.column :status, :article_status, default: "draft", null: false
        end
      end
    end.up

    article = Article.create

    assert_equal "draft", article.reload.status
  end

  test "adds enum using shortcut" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.article_status :status, default: "draft", null: false
        end
      end
    end.up

    article = Article.create

    assert_equal "draft", article.reload.status
  end

  test "rejects label not in enum" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.column :status, :article_status, default: "draft", null: false
        end
      end
    end.up

    assert_raises(ActiveRecord::StatementInvalid, /invalid input value for enum article_status: "unlisted"/) do
      Article.create(status: "unlisted")
    end
  end

  test "add enum label" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.column :status, :article_status, default: "draft", null: false
        end

        add_enum_label :article_status, "unlisted"
      end
    end.up

    article = Article.create(status: "unlisted")

    assert_equal "unlisted", article.reload.status
  end

  test "add enum label using before option" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
        add_enum_label :article_status, "unlisted", before: "published"
      end
    end.up

    labels = enum_labels(:article_status)

    assert_equal %w[draft unlisted published], labels
  end

  test "add enum label using after option" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
        add_enum_label :article_status, "unlisted", after: "draft"
      end
    end.up

    labels = enum_labels(:article_status)

    assert_equal %w[draft unlisted published], labels
  end

  test "rename label" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
        rename_enum_label :article_status, "draft", "unpublished"
      end
    end.up

    labels = enum_labels(:article_status)

    assert_equal %w[unpublished published], labels
  end

  test "drop enum" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
        drop_enum :article_status
      end
    end.up

    assert ActiveRecord::Base.connection.execute("select * from pg_type where typname = 'article_status'").to_a.empty?
  end

  test "raise exception when dropping enum in use" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.column :status, :article_status
        end
      end
    end.up

    Article.create!(status: "draft")

    assert_raises(ActiveRecord::StatementInvalid, /cannot drop type article_status because other objects depend on it/) do
      with_migration do
        def up
          drop_enum :article_status
        end
      end.up
    end
  end

  test "drop enum when value using cascade" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]

        create_table :articles do |t|
          t.column :status, :article_status
        end
      end
    end.up

    Article.create!(status: "draft")

    with_migration do
      def up
        drop_enum :article_status, cascade: true
      end
    end.up

    Article.reset_column_information
    assert_equal %w[id], Article.columns.map(&:name)
  end

  test "revert create enum" do
    migration = with_migration do
      def change
        create_enum :article_status, %w[draft published]
      end
    end

    migration.migrate(:up)
    assert_equal %w[draft published], enum_labels(:article_status)

    migration.migrate(:down)
    assert_equal [], enum_labels(:article_status)
  end

  test "revert rename enum label" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
      end
    end.up

    migration = with_migration do
      def change
        rename_enum_label :article_status, "published", "live"
      end
    end

    migration.migrate(:up)
    assert_equal %w[draft live], enum_labels(:article_status)

    migration.migrate(:down)
    assert_equal %w[draft published], enum_labels(:article_status)
  end

  test "dumps schema" do
    with_migration do
      def up
        create_enum :article_status, %w[draft published]
        create_enum :color, %w[blue green yellow]

        create_table :articles do |t|
          t.column :status, :article_status
          t.column :background, :color
        end
      end
    end.up

    with_migration do
      def up
        add_enum_label :article_status, "unlisted", after: "draft"
      end
    end.up

    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    contents = stream.tap(&:rewind).read

    assert_includes contents, %{create_enum :article_status, ["draft", "unlisted", "published"]}
    assert_includes contents, %{create_enum :color, ["blue", "green", "yellow"]}
    assert_includes contents, %[create_table "articles"]
    assert_includes contents, %[t.article_status "status"]
    assert_includes contents, %[t.color "background"]
    refute_includes contents, %[Could not dump table "articles"]
  end

  test "loads dumped schema" do
    migrations = []

    migrations << with_migration do
      def change
        create_enum :article_status, %w[draft published]
        create_enum :color, %w[blue green yellow]

        create_table :articles do |t|
          t.column :status, :article_status
          t.column :background, :color
        end
      end
    end

    assert_equal 0, ActiveRecord::Base.connection.enum_types.to_a.size

    migrations.each {|migration| migration.migrate(:up) }

    assert_equal 2, ActiveRecord::Base.connection.enum_types.to_a.size

    stream = StringIO.new
    ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, stream)
    contents = stream.tap(&:rewind).read

    migrations.each {|migration| migration.migrate(:down) }

    assert_equal 0, ActiveRecord::Base.connection.enum_types.to_a.size

    eval(contents)

    assert_equal 2, ActiveRecord::Base.connection.enum_types.to_a.size

    assert_equal %i[article_status color integer], Article.columns.map(&:type).sort
  end
end
