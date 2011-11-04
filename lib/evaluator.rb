require 'rubygems'
require 'nokogiri'

class Evaluator
  def assert(boolean)
    raise SyntaxError unless boolean
  end
  
  class Evaluation
    # We only support ordered parameters now. Named params to come
    # only support integer arguments

    # Create a binding
    def initialize(call, defn)
      @defn = defn
      parameters = defn.xpath('ul').xpath('li')
      arguments = call.xpath('ul').xpath('li')

      parameters.zip(arguments).each do |param, arg|
        instance_variable_set(:"@#{param.text}", arg.text.to_i)
        eval("class << self; attr_reader :#{param.text}; end")
      end
    end

    def e
      instance_eval(@defn.children.last)
    end
  end
  
  def initialize(code)
    @code = code
  end
  
  def e
    ast = Nokogiri.parse(@code)

    @environment = {}
    function_defns = ast.xpath('//div')
    function_defns.each do |defn|
      ids = defn.xpath('@id')
      assert ids.size == 1
      name = ids.first.value
      @environment[name] = defn
    end

    function_calls = ast.xpath('//a')
    function_calls.each do |call|
      hrefs = call.xpath('@href')
      assert hrefs.size == 1
      name = hrefs.first.value[1..-1]

      defn = @environment[name]
      e = Evaluation.new(call, defn)
      call.replace(ast.create_element("span", e.e))
    end

    ast.inner_html
  end
end
