require 'rubygems'
require 'nokogiri'

f = File.open('examples/add.html')
code = f.read

ast = Nokogiri.parse(code)

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
      #{}"#{param.text} => #{arg.text.to_i}"
      instance_variable_set(:"@#{param.text}", arg.text.to_i)
      eval("class << self; attr_reader :#{param.text}; end")
    end
  end
  
  def e
    instance_eval(@defn.children.last)
  end
end

# Populate the environment with function definitions
function_defns = ast.xpath('//div')

@environment = {}

function_defns.each do |defn|
  ids = defn.xpath('@id')
  assert ids.size == 1
  name = ids.first.value
  @environment[name] = defn
end

function_calls = ast.xpath('//a')

# p function_calls

function_calls.each do |call|
  hrefs = call.xpath('@href')
  assert hrefs.size == 1
  name = hrefs.first.value[1..-1]
  
  # Need both a call and a defn
  defn = @environment[name]
  
  e = Evaluation.new(call, defn)
  
  # Replace the call with the result
  
  call.replace(ast.create_element("span", e.e))
  
end

p ast.inner_html