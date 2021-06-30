require "bundler/inline"

gemfile do
  source "https://rubygems.org"

  gem "graphql"
  gem "concurrent-ruby"
  gem "benchmark-ips"
  gem "pry-byebug"
  gem "ruby-prof"
end

query = <<~Q
  query {
    articles {
      slug, title, position, category
      relatedArticles {
        slug, title, position, category
        parent {
          slug, title, position, category
        }
      }
    }
  }
Q

module Test
  module Types
    Article = Struct.new(:slug, :title, :position, :category, :related_articles, :parent, keyword_init: true)

    ALL_ARTICLES = Array.new(20) do |i|
      Article.new(
        slug: "slug#{i}",
        title: "title#{i}",
        position: i,
        category: "category#{i}"
      ).tap do |a|
        a.related_articles = Array.new(50) do |j|
          Article.new(
            slug: "slug#{j}",
            title: "title#{j}",
            position: j,
            category: "category#{j}",
            parent: a
          )
        end
      end
    end

    class CategoryType < GraphQL::Schema::Enum
      (ALL_ARTICLES + ALL_ARTICLES.flat_map(&:related_articles)).map(&:category).uniq.each do |category|
        value category
      end
    end

    class ArticleType < GraphQL::Schema::Object
      field :slug, ID, null: false
      field :title, String, null: false
      field :category, CategoryType, null: false
      field :position, Integer, null: false
      field :related_articles, [ArticleType], null: false
      field :parent, ArticleType, null: true
    end

    class QueryType < GraphQL::Schema::Object
      field :articles, [ArticleType], null: true

      def articles
        ALL_ARTICLES
      end
    end
  end
end

class TestSchema < GraphQL::Schema
  query Test::Types::QueryType
end

if ENV['PROFILE']
  result = RubyProf.profile do
    TestSchema.execute(query)
  end

  printer = RubyProf::FlatPrinter.new(result)
  printer.print(File.open("reports/flat_printer.txt", "w"))
  printer = RubyProf::CallStackPrinter.new(result)
  printer.print(File.open("reports/call_stack_printer.html", "w"))
  exit
end

started_at = Time.now
N = 10
N.times do
  raise unless TestSchema.execute(query)['data']['articles'].count == 20
end

duration = Time.now - started_at
puts "#{duration} seconds in total"
puts "#{duration / N * 1000} ms per iteration"
