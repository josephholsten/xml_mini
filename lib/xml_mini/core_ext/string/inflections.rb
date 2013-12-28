require 'xml_mini/inflector'

# String inflections define new methods on the String class to transform names for different purposes.
# For instance, you can figure out the name of a table from the name of a class.
#
#   'ScaleScore'.tableize # => "scale_scores"
#
class String
  # The reverse of +pluralize+, returns the singular form of a word in a string.
  #
  # If the optional parameter +locale+ is specified,
  # the word will be singularized as a word of that language.
  # By default, this parameter is set to <tt>:en</tt>.
  # You must define your own inflection rules for languages other than English.
  #
  #   'posts'.singularize            # => "post"
  #   'octopi'.singularize           # => "octopus"
  #   'sheep'.singularize            # => "sheep"
  #   'word'.singularize             # => "word"
  #   'the blue mailmen'.singularize # => "the blue mailman"
  #   'CamelOctopi'.singularize      # => "CamelOctopus"
  #   'leyes'.singularize(:es)       # => "ley"
  def singularize(locale = :en)
    XmlMini::Inflector.singularize(self, locale)
  end
end
