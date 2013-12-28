require 'helper'

module XmlMiniTest
  class RenameKeyTest < MiniTest::Spec
    def test_rename_key_dasherizes_by_default
      assert_equal "my-key", XmlMini.rename_key("my_key")
    end

    def test_rename_key_does_nothing_with_dasherize_true
      assert_equal "my-key", XmlMini.rename_key("my_key", :dasherize => true)
    end

    def test_rename_key_does_nothing_with_dasherize_false
      assert_equal "my_key", XmlMini.rename_key("my_key", :dasherize => false)
    end

    def test_rename_key_camelizes_with_camelize_true
      assert_equal "MyKey", XmlMini.rename_key("my_key", :camelize => true)
    end

    def test_rename_key_lower_camelizes_with_camelize_lower
      assert_equal "myKey", XmlMini.rename_key("my_key", :camelize => :lower)
    end

    def test_rename_key_lower_camelizes_with_camelize_upper
      assert_equal "MyKey", XmlMini.rename_key("my_key", :camelize => :upper)
    end

    def test_rename_key_does_not_dasherize_leading_underscores
      assert_equal "_id", XmlMini.rename_key("_id")
    end

    def test_rename_key_with_leading_underscore_dasherizes_interior_underscores
      assert_equal "_my-key", XmlMini.rename_key("_my_key")
    end

    def test_rename_key_does_not_dasherize_trailing_underscores
      assert_equal "id_", XmlMini.rename_key("id_")
    end

    def test_rename_key_with_trailing_underscore_dasherizes_interior_underscores
      assert_equal "my-key_", XmlMini.rename_key("my_key_")
    end

    def test_rename_key_does_not_dasherize_multiple_leading_underscores
      assert_equal "__id", XmlMini.rename_key("__id")
    end

    def test_rename_key_does_not_dasherize_multiple_trailing_underscores
      assert_equal "id__", XmlMini.rename_key("id__")
    end
  end

  class ToTagTest < MiniTest::Spec
    def assert_xml(xml)
      assert_equal xml, @options[:builder].target!
    end

    def setup
      @xml = XmlMini
      @options = {:skip_instruct => true, :builder => Builder::XmlMarkup.new}
    end

    def test_to_tag_accepts_a_callable_object_and_passes_options_with_the_builder
      @xml.to_tag(:some_tag, lambda {|o| o[:builder].br }, @options)
      assert_xml "<br/>"
    end

    def test_to_tag_accepts_a_callable_object_and_passes_options_and_tag_name
      @xml.to_tag(:tag, lambda {|o, t| o[:builder].b(t) }, @options)
      assert_xml "<b>tag</b>"
    end

    def test_to_tag_accepts_an_object_responding_to__to_xml_and_passes_the_options_where_root_is_key
      obj = Object.new
      obj.instance_eval do
        def to_xml(options) options[:builder].yo(options[:root].to_s) end
      end

      @xml.to_tag(:tag, obj, @options)
      assert_xml "<yo>tag</yo>"
    end

    def test_to_tag_accepts_arbitrary_objects_responding_to_to_str
      @xml.to_tag(:b, "Howdy", @options)
      assert_xml "<b>Howdy</b>"
    end

    def test_to_tag_should_dasherize_the_space_when_passed_a_string_with_spaces_as_a_key
      @xml.to_tag("New   York", 33, @options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end

    def test_to_tag_should_dasherize_the_space_when_passed_a_symbol_with_spaces_as_a_key
      @xml.to_tag(:"New   York", 33, @options)
      assert_xml "<New---York type=\"integer\">33</New---York>"
    end
    # TODO: test the remaining functions hidden in #to_tag.
  end

  class WithBackendTest < MiniTest::Spec
    module REXML end
    module LibXML end
    module Nokogiri end

    def setup
      @xml, @default_backend = XmlMini, XmlMini.backend
    end

    def teardown
      XmlMini.backend = @default_backend
    end

    def test_with_backend_should_switch_backend_and_then_switch_back
      @xml.backend = REXML
      @xml.with_backend(LibXML) do
        assert_equal LibXML, @xml.backend
        @xml.with_backend(Nokogiri) do
          assert_equal Nokogiri, @xml.backend
        end
        assert_equal LibXML, @xml.backend
      end
      assert_equal REXML, @xml.backend
    end

    def test_backend_switch_inside_with_backend_block
      @xml.with_backend(LibXML) do
        @xml.backend = REXML
        assert_equal REXML, @xml.backend
      end
      assert_equal REXML, @xml.backend
    end
  end

  class ThreadSafetyTest < MiniTest::Spec
    module REXML end
    module LibXML end

    def setup
      @xml, @default_backend = XmlMini, XmlMini.backend
    end

    def teardown
      XmlMini.backend = @default_backend
    end

    def test_with_backend_should_be_thread_safe
      @xml.backend = REXML
      t = Thread.new do
        @xml.with_backend(LibXML) { sleep 1 }
      end
      sleep 0.1 while t.status != "sleep"

      # We should get `old_backend` here even while another
      # thread is using `new_backend`.
      assert_equal REXML, @xml.backend
    end

    def test_nested__with_backend_should_be_thread_safe
      @xml.with_backend(REXML) do
        t = Thread.new do
          @xml.with_backend(LibXML) { sleep 1 }
        end
        sleep 0.1 while t.status != "sleep"

        assert_equal REXML, @xml.backend
      end
    end
  end
end
