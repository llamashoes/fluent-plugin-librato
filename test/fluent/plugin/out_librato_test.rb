require 'fluent/test'
require_relative '../../../lib/fluent/plugin/out_librato'

class LibratoOutputTest < Test::Unit::TestCase

  CONFIG = %[
    email fake@email.com
    apikey this_is_an_api_key
  ]

  setup do
    Fluent::Test.setup
    @tag = 'test'
    @time = Fluent::Engine.now
  end

  def create_driver(conf)
    Fluent::Test::BufferedOutputTestDriver.new(Fluent::LibratoOutput, @tag).configure(conf)
  end

  def test_source_length_warning
    d = create_driver(CONFIG)
    d.instance.validate_fields({'source' => 'b' * 64, 'key' => 'valid_key'})

    assert_equal 1, d.instance.log.out.logs.length
    assert_match /\[warn\]: Source value is longer than 63 characters and will be truncated in Librato/, d.instance.log.out.logs[0]
  end 

  def test_source_invalid_character_warning
    d = create_driver(CONFIG)
    d.instance.validate_fields({'source' => 'invalid\source', 'key' => 'valid_key'})

    assert_equal 1, d.instance.log.out.logs.length
    assert_match /\[error\]: Source value may only contain characters 'A-Za-z0-9.:-_'/, d.instance.log.out.logs[0]
  end 


  def test_measurement_length_warning
    d = create_driver(CONFIG)
    d.instance.validate_fields({'source' => 'valid_source', 'key' => 'b' * 64})

    assert_equal 1, d.instance.log.out.logs.length
    assert_match /\[warn\]: Measurement value is longer than 63 characters and will be truncated in Librato/, d.instance.log.out.logs[0]
  end

  def test_measurement_invalid_character_warning
    d = create_driver(CONFIG)
    d.instance.validate_fields({'source' => 'valid_source', 'key' => 'invalid\key'})

    assert_equal 1, d.instance.log.out.logs.length
    assert_match /\[error\]: Measurement value may only contain characters 'A-Za-z0-9.:-_'/, d.instance.log.out.logs[0]
  end 

end
