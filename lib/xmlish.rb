module Xmlish

  # @param str [String]
  # @param callbacks [Array<#call>]
  # @return [String]
  def self.parse str, callbacks=nil
    reconstruct_from_nodes parse_to_nodes(str, callbacks.keys), callbacks
  end

  # @param str [String]
  # @param callbacks [Array<#call>]
  # @return [void]
  def self.walk str, callbacks=nil
    walk_nodes parse_to_nodes(str, callbacks.keys), callbacks
  end

  private

  # @param str [String]
  # @return [Array<Node>]
  def self.parse_to_nodes str, tag_names
    Parser.new(str, tag_names).parse
  end

  # @param nodes [Array<Node>]
  # @param callbacks [Array<#call>]
  # @return [String]
  def self.reconstruct_from_nodes nodes, callbacks={}
    Reconstructor.new(nodes, callbacks).reconstruct
  end

  # @param nodes [Array<Node>]
  # @param callbacks [Array<#call>]
  # @return [void]
  def self.walk_nodes nodes, callbacks={}
    Walker.new(nodes, callbacks).walk
  end

  class Node < Struct.new(:nodes, :attr_name)
  end

  class Parser
    def initialize str, tag_names
      @str = str
      @tag_names = tag_names
    end

    def parse
      normalise(parse_string @str)
    end

    private

    # @param s [String] like "Press <red>e</red> to edit"
    def parse_string s
      [].tap do |nodes|
        while s.length > 0
          head, tag_name = nil, nil
          begin
            head, tag_name = (m=s.match(/[^<]*<([A-Za-z0-9]+)>/)).to_a
          end until tag_name.nil? || begin
            @tag_names.include?(tag_name).tap do |incl|
              unless incl
                nodes << head
                s = s[head.length, s.length]
              end
            end
          end
          if tag_name.nil?
            nodes << s
            break
          end
          text = head[0, head.length - tag_name.length - '<>'.length]
          nodes << text unless text.length == 0
          s = s[head.length, s.length]
          head = s.match(/.*?<\/#{tag_name}>/).to_a.first
          node_text = head[0, head.length - tag_name.length - '</>'.length]
          node_text = parse_string(node_text)
          nodes << Node.new(node_text, tag_name)
          s = s[head.length, s.length]
        end
      end
    end

    # @param nodes [Array<Node,String>]
    # @return [Array<Node,String>]
    def normalise nodes
      nodes.each do |node|
        if Node === node
          node.nodes = join_adjacent_strings node.nodes
          normalise node.nodes
        end
      end
    end

    # @param nodes [Array<Node,String>]
    # @return [Array<Node,String>]
    def join_adjacent_strings nodes
      nodes.inject [] do |a, b|
        if b.is_a?(String) && a.last.is_a?(String)
          (a[0, a.length-1] + ["#{a.last}#{b}"])
        else
          [a, b]
        end.flatten
      end
    end
  end

  class Reconstructor
    # @param nodes [Array<Node>]
    # @param callbacks [Array<#call>]
    def initialize nodes, callbacks
      @nodes = nodes
      @callbacks = callbacks
    end

    # @return [String]
    def reconstruct nodes=@nodes
      nodes.collect do |node|
        if Node === node
          callback = callback_for_tag node.attr_name
          if callback
            callback.call(reconstruct node.nodes)
          else
            reconstruct node.nodes
          end
        else
          callback = callback_for_tag 'text'
          if callback
            callback.call(node)
          else
            node
          end
        end
      end.join('')
    end

    private

    def callback_for_tag tag
      if @callbacks.has_key? tag
        @callbacks[tag] || identity_callback
      else
        nil
      end
    end

    def identity_callback
      lambda{|s|s}
    end

  end

  class Walker
    # @param nodes [Array<Node>]
    # @param callbacks [Array<#call>]
    def initialize nodes, callbacks
      @nodes = nodes
      @callbacks = callbacks
    end

    # @return [String]
    def walk nodes=@nodes
      nodes.collect do |node|
        if Node === node
          callback = callback_for_tag node.attr_name
          if callback
            callback.call(Proc.new{walk node.nodes})
          else
            walk node.nodes
          end
        else
          callback = callback_for_tag 'text'
          if callback
            callback.call(Proc.new{node})
          else
            node
          end
        end
      end.join('')
    end

    private

    def callback_for_tag tag
      if @callbacks.has_key? tag
        @callbacks[tag] || identity_callback
      else
        nil
      end
    end

    def identity_callback
      lambda{|s|s.call}
    end

  end

end
