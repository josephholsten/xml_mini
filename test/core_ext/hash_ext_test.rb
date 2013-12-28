require 'helper'
require 'bigdecimal'
require 'xml_mini/core_ext/hash'
require 'xml_mini/core_ext/array/conversions'

class IWriteMyOwnXML
  def to_xml(options = {})
    options[:indent] ||= 2
    xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
    xml.instruct! unless options[:skip_instruct]
    xml.level_one do
      xml.tag!(:second_level, 'content')
    end
  end
end

class HashToXmlTest < MiniTest::Spec
  def setup
    @xml_options = { :root => :person, :skip_instruct => true, :indent => 0 }
  end

  def test_one_level
    xml = { :name => "David", :street => "Paulina" }.to_xml(@xml_options)
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_dasherize_false
    xml = { :name => "David", :street_name => "Paulina" }.to_xml(@xml_options.merge(:dasherize => false))
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street_name>Paulina</street_name>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_dasherize_true
    xml = { :name => "David", :street_name => "Paulina" }.to_xml(@xml_options.merge(:dasherize => true))
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street-name>Paulina</street-name>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_camelize_true
    xml = { :name => "David", :street_name => "Paulina" }.to_xml(@xml_options.merge(:camelize => true))
    assert_equal "<Person>", xml[0,8]
    assert xml.include?(%(<StreetName>Paulina</StreetName>))
    assert xml.include?(%(<Name>David</Name>))
  end

  def test_one_level_camelize_lower
    xml = { :name => "David", :street_name => "Paulina" }.to_xml(@xml_options.merge(:camelize => :lower))
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<streetName>Paulina</streetName>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_one_level_with_types
    xml = { :name => "David", :street => "Paulina", :age => 26, :age_in_millis => 820497600000, :moved_on => Date.new(2005, 11, 15), :resident => :yes }.to_xml(@xml_options)
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age type="integer">26</age>))
    assert xml.include?(%(<age-in-millis type="integer">820497600000</age-in-millis>))
    assert xml.include?(%(<moved-on type="date">2005-11-15</moved-on>))
    assert xml.include?(%(<resident type="symbol">yes</resident>))
  end

  def test_one_level_with_nils
    xml = { :name => "David", :street => "Paulina", :age => nil }.to_xml(@xml_options)
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age nil="true"/>))
  end

  def test_one_level_with_skipping_types
    xml = { :name => "David", :street => "Paulina", :age => nil }.to_xml(@xml_options.merge(:skip_types => true))
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<age nil="true"/>))
  end

  def test_one_level_with_yielding
    xml = { :name => "David", :street => "Paulina" }.to_xml(@xml_options) do |x|
      x.creator("Rails")
    end

    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<street>Paulina</street>))
    assert xml.include?(%(<name>David</name>))
    assert xml.include?(%(<creator>Rails</creator>))
  end

  def test_two_levels
    xml = { :name => "David", :address => { :street => "Paulina" } }.to_xml(@xml_options)
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<address><street>Paulina</street></address>))
    assert xml.include?(%(<name>David</name>))
  end

  def test_two_levels_with_second_level_overriding_to_xml
    xml = { :name => "David", :address => { :street => "Paulina" }, :child => IWriteMyOwnXML.new }.to_xml(@xml_options)
    assert_equal "<person>", xml[0,8]
    assert xml.include?(%(<address><street>Paulina</street></address>))
    assert xml.include?(%(<level_one><second_level>content</second_level></level_one>))
  end

# TODO: fix singularize
#   def test_two_levels_with_array
#     xml = { :name => "David", :addresses => [{ :street => "Paulina" }, { :street => "Evergreen" }] }.to_xml(@xml_options)
#     assert_equal "<person>", xml[0,8]
#     assert xml.include?(%(<addresses type="array"><address>)), xml
#     assert xml.include?(%(<address><street>Paulina</street></address>))
#     assert xml.include?(%(<address><street>Evergreen</street></address>))
#     assert xml.include?(%(<name>David</name>))
#   end

# TODO: generating xml
#   def test_three_levels_with_array
#     xml = { :name => "David", :addresses => [{ :streets => [ { :name => "Paulina" }, { :name => "Paulina" } ] } ] }.to_xml(@xml_options)
#     assert xml.include?(%(<addresses type="array"><address><streets type="array"><street><name>))
#   end

# TODO: fix timezone support
#   def test_timezoned_attributes
#     xml = {
#       :created_at => Time.utc(1999,2,2),
#       :local_created_at => Time.utc(1999,2,2).in_time_zone('Eastern Time (US & Canada)')
#     }.to_xml(@xml_options)
#     assert_match %r{<created-at type=\"dateTime\">1999-02-02T00:00:00Z</created-at>}, xml
#     assert_match %r{<local-created-at type=\"dateTime\">1999-02-01T19:00:00-05:00</local-created-at>}, xml
#   end

# TODO: fix timezone support
#   def test_multiple_records_from_xml_with_attributes_other_than_type_ignores_them_without_exploding
#     topics_xml = <<-EOT
#       <topics type="array" page="1" page-count="1000" per-page="2">
#         <topic>
#           <title>The First Topic</title>
#           <author-name>David</author-name>
#           <id type="integer">1</id>
#           <approved type="boolean">false</approved>
#           <replies-count type="integer">0</replies-count>
#           <replies-close-in type="integer">2592000000</replies-close-in>
#           <written-on type="date">2003-07-16</written-on>
#           <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
#           <content>Have a nice day</content>
#           <author-email-address>david@loudthinking.com</author-email-address>
#           <parent-id nil="true"></parent-id>
#         </topic>
#         <topic>
#           <title>The Second Topic</title>
#           <author-name>Jason</author-name>
#           <id type="integer">1</id>
#           <approved type="boolean">false</approved>
#           <replies-count type="integer">0</replies-count>
#           <replies-close-in type="integer">2592000000</replies-close-in>
#           <written-on type="date">2003-07-16</written-on>
#           <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
#           <content>Have a nice day</content>
#           <author-email-address>david@loudthinking.com</author-email-address>
#           <parent-id></parent-id>
#         </topic>
#       </topics>
#     EOT
# 
#     expected_topic_hash = {
#       'title' => "The First Topic",
#       'author_name '=> "David",
#       'id' => 1,
#       'approved' => false,
#       'replies_count' => 0,
#       'replies_close_in' => 2592000000,
#       'written_on' => Date.new(2003, 7, 16),
#       'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
#       'content' => "Have a nice day",
#       'author_email_address' => "david@loudthinking.com",
#       'parent_id' => nil
#     }
# 
#     assert_equal expected_topic_hash, Hash.from_xml(topics_xml)["topics"].first
#   end

# TODO: fix timezone support
#   def test_single_record_from_xml
#     topic_xml = <<-EOT
#       <topic>
#         <title>The First Topic</title>
#         <author-name>David</author-name>
#         <id type="integer">1</id>
#         <approved type="boolean"> true </approved>
#         <replies-count type="integer">0</replies-count>
#         <replies-close-in type="integer">2592000000</replies-close-in>
#         <written-on type="date">2003-07-16</written-on>
#         <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
#         <author-email-address>david@loudthinking.com</author-email-address>
#         <parent-id></parent-id>
#         <ad-revenue type="decimal">1.5</ad-revenue>
#         <optimum-viewing-angle type="float">135</optimum-viewing-angle>
#       </topic>
#     EOT
# 
#     expected_topic_hash = {
#       'title' => "The First Topic",
#       'author_name' => "David",
#       'id' => 1,
#       'approved' => true,
#       'replies_count' => 0,
#       'replies_close_in' => 2592000000,
#       'written_on' => Date.new(2003, 7, 16),
#       'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
#       'author_email_address' => "david@loudthinking.com",
#       'parent_id' => nil,
#       'ad_revenue' => BigDecimal("1.50"),
#       'optimum_viewing_angle' => 135.0,
#     }
# 
#     assert_equal expected_topic_hash, Hash.from_xml(topic_xml)["topic"]
#   end

  def test_single_record_from_xml_with_nil_values
    topic_xml = <<-EOT
      <topic>
        <title></title>
        <id type="integer"></id>
        <approved type="boolean"></approved>
        <written-on type="date"></written-on>
        <viewed-at type="datetime"></viewed-at>
        <parent-id></parent-id>
      </topic>
    EOT

    expected_topic_hash = {
      'title'      => nil,
      'id'         => nil,
      'approved'   => nil,
      'written_on' => nil,
      'viewed_at'  => nil,
      'parent_id'  => nil
    }

    assert_equal expected_topic_hash, Hash.from_xml(topic_xml)["topic"]
  end

# TODO: fix timezone support
#   def test_multiple_records_from_xml
#     topics_xml = <<-EOT
#       <topics type="array">
#         <topic>
#           <title>The First Topic</title>
#           <author-name>David</author-name>
#           <id type="integer">1</id>
#           <approved type="boolean">false</approved>
#           <replies-count type="integer">0</replies-count>
#           <replies-close-in type="integer">2592000000</replies-close-in>
#           <written-on type="date">2003-07-16</written-on>
#           <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
#           <content>Have a nice day</content>
#           <author-email-address>david@loudthinking.com</author-email-address>
#           <parent-id nil="true"></parent-id>
#         </topic>
#         <topic>
#           <title>The Second Topic</title>
#           <author-name>Jason</author-name>
#           <id type="integer">1</id>
#           <approved type="boolean">false</approved>
#           <replies-count type="integer">0</replies-count>
#           <replies-close-in type="integer">2592000000</replies-close-in>
#           <written-on type="date">2003-07-16</written-on>
#           <viewed-at type="datetime">2003-07-16T09:28:00+0000</viewed-at>
#           <content>Have a nice day</content>
#           <author-email-address>david@loudthinking.com</author-email-address>
#           <parent-id></parent-id>
#         </topic>
#       </topics>
#     EOT
# 
#     expected_topic_hash = {
#       'title' => "The First Topic",
#       'author_name' => "David",
#       'id' => 1,
#       'approved' => false,
#       'replies_count' => 0,
#       'replies_close_in' => 2592000000,
#       'written_on' => Date.new(2003, 7, 16),
#       'viewed_at' => Time.utc(2003, 7, 16, 9, 28),
#       'content' => "Have a nice day",
#       'author_email_address' => "david@loudthinking.com",
#       'parent_id' => nil
#     }
# 
#     assert_equal expected_topic_hash, Hash.from_xml(topics_xml)["topics"].first
#   end

  def test_single_record_from_xml_with_attributes_other_than_type
    topic_xml = <<-EOT
    <rsp stat="ok">
      <photos page="1" pages="1" perpage="100" total="16">
        <photo id="175756086" owner="55569174@N00" secret="0279bf37a1" server="76" title="Colored Pencil PhotoBooth Fun" ispublic="1" isfriend="0" isfamily="0"/>
      </photos>
    </rsp>
    EOT

    expected_topic_hash = {
      'id' => "175756086",
      'owner' => "55569174@N00",
      'secret' => "0279bf37a1",
      'server' => "76",
      'title' => "Colored Pencil PhotoBooth Fun",
      'ispublic' => "1",
      'isfriend' => "0",
      'isfamily' => "0",
    }

    assert_equal expected_topic_hash, Hash.from_xml(topic_xml)["rsp"]["photos"]["photo"]
  end

   def test_all_caps_key_from_xml
     test_xml = <<-EOT
       <ABC3XYZ>
         <TEST>Lorem Ipsum</TEST>
       </ABC3XYZ>
     EOT

     expected_hash = {
       "ABC3XYZ" => {
         "TEST" => "Lorem Ipsum"
       }
     }

     assert_equal expected_hash, Hash.from_xml(test_xml)
   end

  def test_empty_array_from_xml
    blog_xml = <<-XML
      <blog>
        <posts type="array"></posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    assert_equal expected_blog_hash, Hash.from_xml(blog_xml)
  end

  def test_empty_array_with_whitespace_from_xml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => []}}
    assert_equal expected_blog_hash, Hash.from_xml(blog_xml)
  end

  def test_array_with_one_entry_from_xml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post"]}}
    assert_equal expected_blog_hash, Hash.from_xml(blog_xml)
  end

  def test_array_with_multiple_entries_from_xml
    blog_xml = <<-XML
      <blog>
        <posts type="array">
          <post>a post</post>
          <post>another post</post>
        </posts>
      </blog>
    XML
    expected_blog_hash = {"blog" => {"posts" => ["a post", "another post"]}}
    assert_equal expected_blog_hash, Hash.from_xml(blog_xml)
  end

  def test_file_from_xml
    blog_xml = <<-XML
      <blog>
        <logo type="file" name="logo.png" content_type="image/png">
        </logo>
      </blog>
    XML
    hash = Hash.from_xml(blog_xml)
    assert hash.has_key?('blog')
    assert hash['blog'].has_key?('logo')

    file = hash['blog']['logo']
    assert_equal 'logo.png', file.original_filename
    assert_equal 'image/png', file.content_type
  end

  def test_file_from_xml_with_defaults
    blog_xml = <<-XML
      <blog>
        <logo type="file">
        </logo>
      </blog>
    XML
    file = Hash.from_xml(blog_xml)['blog']['logo']
    assert_equal 'untitled', file.original_filename
    assert_equal 'application/octet-stream', file.content_type
  end

  def test_tag_with_attrs_and_whitespace
    xml = <<-XML
      <blog name="bacon is the best">
      </blog>
    XML
    hash = Hash.from_xml(xml)
    assert_equal "bacon is the best", hash['blog']['name']
  end

  def test_empty_cdata_from_xml
    xml = "<data><![CDATA[]]></data>"

    assert_equal "", Hash.from_xml(xml)["data"]
  end

#   def test_xsd_like_types_from_xml
#     bacon_xml = <<-EOT
#     <bacon>
#       <weight type="double">0.5</weight>
#       <price type="decimal">12.50</price>
#       <chunky type="boolean"> 1 </chunky>
#       <expires-at type="dateTime">2007-12-25T12:34:56+0000</expires-at>
#       <notes type="string"></notes>
#       <illustration type="base64Binary">YmFiZS5wbmc=</illustration>
#       <caption type="binary" encoding="base64">VGhhdCdsbCBkbywgcGlnLg==</caption>
#     </bacon>
#     EOT
# 
#     expected_bacon_hash = {
#       'weight' => 0.5,
#       'chunky' => true,
#       'price' => BigDecimal("12.50"),
#       'expires_at' => Time.utc(2007,12,25,12,34,56),
#       'notes' => "",
#       'illustration' => "babe.png",
#       'caption' => "That'll do, pig."
#     }
# 
#     assert_equal expected_bacon_hash, Hash.from_xml(bacon_xml)["bacon"]
#   end

  def test_type_trickles_through_when_unknown
    product_xml = <<-EOT
    <product>
      <weight type="double">0.5</weight>
      <image type="ProductImage"><filename>image.gif</filename></image>

    </product>
    EOT

    expected_product_hash = {
      'weight' => 0.5,
      'image' => {'type' => 'ProductImage', 'filename' => 'image.gif' },
    }

    assert_equal expected_product_hash, Hash.from_xml(product_xml)["product"]
  end

  def test_from_xml_raises_on_disallowed_type_attributes
    assert_raises XmlMini::XMLConverter::DisallowedType do
      Hash.from_xml '<product><name type="foo">value</name></product>', %w(foo)
    end
  end

  def test_from_xml_disallows_symbol_and_yaml_types_by_default
    assert_raises XmlMini::XMLConverter::DisallowedType do
      Hash.from_xml '<product><name type="symbol">value</name></product>'
    end

    assert_raises XmlMini::XMLConverter::DisallowedType do
      Hash.from_xml '<product><name type="yaml">value</name></product>'
    end
  end

#   def test_from_trusted_xml_allows_symbol_and_yaml_types
#     expected = { 'product' => { 'name' => :value }}
#     assert_equal expected, Hash.from_trusted_xml('<product><name type="symbol">value</name></product>')
#     assert_equal expected, Hash.from_trusted_xml('<product><name type="yaml">:value</name></product>')
#   end

  # The XML builder seems to fail miserably when trying to tag something
  # with the same name as a Kernel method (throw, test, loop, select ...)
  def test_kernel_method_names_to_xml
    hash     = { :throw => { :ball => 'red' } }
    expected = '<person><throw><ball>red</ball></throw></person>'

    # should not raise
    assert_equal expected, hash.to_xml(@xml_options)
  end

  def test_empty_string_works_for_typecast_xml_value
    # should not raise
    XmlMini::XMLConverter.new("").to_h
  end

  def test_escaping_to_xml
    hash = {
      'bare_string'        => 'First & Last Name',
      'pre_escaped_string' => 'First &amp; Last Name'
    }

    expected_xml = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    assert_equal expected_xml, hash.to_xml(@xml_options)
  end

  def test_unescaping_from_xml
    xml_string = '<person><bare-string>First &amp; Last Name</bare-string><pre-escaped-string>First &amp;amp; Last Name</pre-escaped-string></person>'
    expected_hash = {
      'bare_string'        => 'First & Last Name',
      'pre_escaped_string' => 'First &amp; Last Name'
    }

    assert_equal expected_hash, Hash.from_xml(xml_string)['person']
  end

  def test_roundtrip_to_xml_from_xml
    hash = {
      'bare_string'        => 'First & Last Name',
      'pre_escaped_string' => 'First &amp; Last Name'
    }

    assert_equal hash, Hash.from_xml(hash.to_xml(@xml_options))['person']
  end

#   def test_datetime_xml_type_with_utc_time
#     alert_xml = <<-XML
#       <alert>
#         <alert_at type="datetime">2008-02-10T15:30:45Z</alert_at>
#       </alert>
#     XML
#     alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
#     assert alert_at.utc?
#     assert_equal Time.utc(2008, 2, 10, 15, 30, 45), alert_at
#   end

#   def test_datetime_xml_type_with_non_utc_time
#     alert_xml = <<-XML
#       <alert>
#         <alert_at type="datetime">2008-02-10T10:30:45-05:00</alert_at>
#       </alert>
#     XML
#     alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
#     assert alert_at.utc?
#     assert_equal Time.utc(2008, 2, 10, 15, 30, 45), alert_at
#   end

#   def test_datetime_xml_type_with_far_future_date
#     alert_xml = <<-XML
#       <alert>
#         <alert_at type="datetime">2050-02-10T15:30:45Z</alert_at>
#       </alert>
#     XML
#     alert_at = Hash.from_xml(alert_xml)['alert']['alert_at']
#     assert alert_at.utc?
#     assert_equal 2050,  alert_at.year
#     assert_equal 2,     alert_at.month
#     assert_equal 10,    alert_at.day
#     assert_equal 15,    alert_at.hour
#     assert_equal 30,    alert_at.min
#     assert_equal 45,    alert_at.sec
#   end

  def test_to_xml_dups_options
    options = {:skip_instruct => true}
    {}.to_xml(options)
    # :builder, etc, shouldn't be added to options
    assert_equal({:skip_instruct => true}, options)
  end

  def test_expansion_count_is_limited
    expected =
      case XmlMini.backend.name
      when 'XmlMini::REXML';        RuntimeError
      when 'XmlMini::Nokogiri';     Nokogiri::XML::SyntaxError
      when 'XmlMini::Nokogiri';     Nokogiri::XML::SyntaxError
      when 'XmlMini::NokogiriSAX';  RuntimeError
      when 'XmlMini::LibXML';       LibXML::XML::Error
      when 'XmlMini::LibXMLSAX';    LibXML::XML::Error
      end

    assert_raises expected do
      attack_xml = <<-EOT
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE member [
        <!ENTITY a "&b;&b;&b;&b;&b;&b;&b;&b;&b;&b;">
        <!ENTITY b "&c;&c;&c;&c;&c;&c;&c;&c;&c;&c;">
        <!ENTITY c "&d;&d;&d;&d;&d;&d;&d;&d;&d;&d;">
        <!ENTITY d "&e;&e;&e;&e;&e;&e;&e;&e;&e;&e;">
        <!ENTITY e "&f;&f;&f;&f;&f;&f;&f;&f;&f;&f;">
        <!ENTITY f "&g;&g;&g;&g;&g;&g;&g;&g;&g;&g;">
        <!ENTITY g "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx">
      ]>
      <member>
      &a;
      </member>
      EOT
      Hash.from_xml(attack_xml)
    end
  end
end

