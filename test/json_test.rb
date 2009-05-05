require 'test_helper'

Crack::JSON.backend = "Yajl"

class JsonTest < Test::Unit::TestCase
  TESTS = {
    %q({"returnTo":{"\/categories":"\/"}})        => {"returnTo" => {"/categories" => "/"}},
    %q({"return\\"To\\":":{"\/categories":"\/"}}) => {"return\"To\":" => {"/categories" => "/"}},
    %q({"returnTo":{"\/categories":1}})          => {"returnTo" => {"/categories" => 1}},
    %({"returnTo":[1,"a"]})                    => {"returnTo" => [1, "a"]},
    %({"returnTo":[1,"\\"a\\",", "b"]})        => {"returnTo" => [1, "\"a\",", "b"]},
    %({"a": "'", "b": "5,000"})                  => {"a" => "'", "b" => "5,000"},
    %({"a": "a's, b's and c's", "b": "5,000"})   => {"a" => "a's, b's and c's", "b" => "5,000"},
    # multibyte
    %({"matzue": "松江", "asakusa": "浅草"}) => {"matzue" => "松江", "asakusa" => "浅草"},
    %({"a": "2007-01-01"})                       => {'a' => DateTime.new(2007, 1, 1)}, 
    %({"a": "2007-01-01 01:12:34 Z"})            => {'a' => Time.utc(2007, 1, 1, 1, 12, 34)},
    # no time zone
    %({"a": "2007-01-01 01:12:34"})              => {'a' => "2007-01-01 01:12:34"}, 
    # needs to be *exact*
    %({"a": " 2007-01-01 01:12:34 Z "})          => {'a' => " 2007-01-01 01:12:34 Z "},
    %({"a": "2007-01-01 : it's your birthday"})  => {'a' => "2007-01-01 : it's your birthday"},
    %([])    => [],
    %({})    => {},
    %({"a":1})     => {"a" => 1},
    %({"a": ""})    => {"a" => ""},
    %({"a":"\\""}) => {"a" => "\""},
    %({"a": null})  => {"a" => nil},
    %({"a": true})  => {"a" => true},
    %({"a": false}) => {"a" => false},
    %q({"a": "http:\/\/test.host\/posts\/1"}) => {"a" => "http://test.host/posts/1"},
    %q({"a": "\u003cunicode\u0020escape\u003e"}) => {"a" => "<unicode escape>"},
    %q({"a": "\\\\u0020skip double backslashes"}) => {"a" => "\\u0020skip double backslashes"},
    %q({"a": "\u003cbr /\u003e"}) => {'a' => "<br />"},
    %q({"b":["\u003ci\u003e","\u003cb\u003e","\u003cu\u003e"]}) => {'b' => ["<i>","<b>","<u>"]}
  }
  
  TESTS.each do |json, expected|
    should "should decode json (#{json})" do
      # lambda {
        Crack::JSON.parse(json).should == expected
      # }.should_not raise_error
    end
  end

  should "should raise error for failed decoding" do
    lambda {
      Crack::JSON.parse('{: 1}')
    }.should raise_error(Crack::ParseError)
  end
  
  should "should be able to parse a JSON response from a Twitter search about 'firefox'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-firefox.json", "r") { |f|
        data = f.read
    }
    
    lambda {
      Crack::JSON.parse(data)
    }.should_not raise_error(Crack::ParseError)
  end

  should "should be able to parse a JSON response from a Twitter search about 'internet explorer'" do
    data = ''
    File.open(File.dirname(__FILE__) + "/data/twittersearch-ie.json", "r") { |f|
        data = f.read
    }
    
    lambda {
      Crack::JSON.parse(data)
    }.should_not raise_error(Crack::ParseError)
  end

end