# encoding: utf-8

module XmlMini
  # The Inflector transforms words from singular to plural, class names to table
  # names, modularized class names to ones without, and class names to foreign
  # keys. The default inflections for pluralization, singularization, and
  # uncountable words are kept in inflections.rb.
  #
  # The Rails core team has stated patches for the inflections library will not
  # be accepted in order to avoid breaking legacy applications which may be
  # relying on errant inflections. If you discover an incorrect inflection and
  # require it for your application or wish to define rules for languages other
  # than English, please correct or add them yourself (explained below).
  module Inflector
    extend self

    # Returns the plural form of the word in the string.
    #
    # If passed an optional +locale+ parameter, the word will be
    # pluralized using rules defined for that language. By default,
    # this parameter is set to <tt>:en</tt>.
    #
    #   'post'.pluralize             # => "posts"
    #   'octopus'.pluralize          # => "octopi"
    #   'sheep'.pluralize            # => "sheep"
    #   'words'.pluralize            # => "words"
    #   'CamelOctopus'.pluralize     # => "CamelOctopi"
    #   'ley'.pluralize(:es)         # => "leyes"
    def pluralize(word, locale = :en)
      # TODO: restore inflections
      apply_inflections(word, [])
    end

    # The reverse of +pluralize+, returns the singular form of a word in a
    # string.
    #
    # If passed an optional +locale+ parameter, the word will be
    # singularized using rules defined for that language. By default,
    # this parameter is set to <tt>:en</tt>.
    #
    #   'posts'.singularize            # => "post"
    #   'octopi'.singularize           # => "octopus"
    #   'sheep'.singularize            # => "sheep"
    #   'word'.singularize             # => "word"
    #   'CamelOctopi'.singularize      # => "CamelOctopus"
    #   'leyes'.singularize(:es)       # => "ley"
    def singularize(word, locale = :en)
      apply_inflections(word, [])
    end

    # By default, +camelize+ converts strings to UpperCamelCase. If the argument
    # to +camelize+ is set to <tt>:lower</tt> then +camelize+ produces
    # lowerCamelCase.
    #
    # +camelize+ will also convert '/' to '::' which is useful for converting
    # paths to namespaces.
    #
    #   'active_model'.camelize                # => "ActiveModel"
    #   'active_model'.camelize(:lower)        # => "activeModel"
    #   'active_model/errors'.camelize         # => "ActiveModel::Errors"
    #   'active_model/errors'.camelize(:lower) # => "activeModel::Errors"
    #
    # As a rule of thumb you can think of +camelize+ as the inverse of
    # +underscore+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    def camelize(term, uppercase_first_letter = true)
      string = term.to_s
      if uppercase_first_letter && uppercase_first_letter != :lower
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
      else
        string = string.sub(/^(?:\w)/) { $&.downcase }
      end
      string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{ $2.capitalize}" }
      string.gsub!('/', '::')
      string
    end

    # Makes an underscored, lowercase form from the expression in the string.
    #
    # Changes '::' to '/' to convert namespaces to paths.
    #
    #   'ActiveModel'.underscore         # => "active_model"
    #   'ActiveModel::Errors'.underscore # => "active_model/errors"
    #
    # As a rule of thumb you can think of +underscore+ as the inverse of
    # +camelize+, though there are cases where that does not hold:
    #
    #   'SSLError'.underscore.camelize # => "SslError"
    def underscore(camel_cased_word)
      word = camel_cased_word.to_s.gsub('::', '/')
      word.gsub!(/(?:([A-Za-z\d])|^)()(?=\b|[^a-z])/) { "#{$1}#{$1 && '_'}#{$2.downcase}" }
      word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
      word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
      word.tr!("-", "_")
      word.downcase!
      word
    end

    private

    # Applies inflection rules for +singularize+ and +pluralize+.
    #
    #  apply_inflections('post', inflections.plurals)    # => "posts"
    #  apply_inflections('posts', inflections.singulars) # => "post"
    def apply_inflections(word, rules)
      result = word.to_s.dup

      if word.empty?
        result
      else
        rules.each { |(rule, replacement)| break if result.sub!(rule, replacement) }
        result
      end
    end
  end
end
