require 'test_helper'

class NonUserClientTest < Test::Unit::TestCase
  def setup
    stub_netflix_public_api
    Netflix::Client.consumer_key = 'foo_consumer_key'
    Netflix::Client.consumer_secret = 'foo_consumer_secret'
    Netflix::Client.app_name = 'my_rad_app'
  end
  
  def test_client
    assert_nothing_raised do
      Netflix::Client.new
    end
  end

  def test_catalog_index
    puts "YOUR FACE"
    client = Netflix::Client.new
    catalog = client.catalog

    assert_equal(catalog.index, ['Some Movie'])
  end
end
