require 'spec_helper'

describe Xmlish do

  Node = Xmlish::Node

  describe "#parse_to_nodes" do

    def parse_to_nodes *args
      Xmlish.send(:parse_to_nodes, *args)
    end

    specify "plain text" do
      parse_to_nodes("test", []).should == ["test"]
    end

    specify "single tag" do
      parse_to_nodes("Press <red>ENTER</red>", ['red']).should ==
        ["Press ", Node.new(["ENTER"], 'red')]
      parse_to_nodes("Press <bold>ENTER</bold>", ['bold']).should ==
        ["Press ", Node.new(["ENTER"], 'bold')]
    end

    specify "nested tags" do
      parse_to_nodes("Press <red><bold>ENTER</bold></red>", ['red', 'bold']).should ==
        ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red')]
    end

    specify "repeated tag" do
      parse_to_nodes("Press <red>ENTER</red> or <red>ESC</red>", ['red']).should ==
        ["Press ", Node.new(["ENTER"], 'red'), " or ", Node.new(["ESC"], 'red')]
    end

    specify "repeated nested tags" do
      parse_to_nodes("Press <red><bold>ENTER</bold></red> or <red><bold>ESC</bold></red>", ['red', 'bold']).should ==
        ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red'), " or ", Node.new([Node.new(["ESC"], 'bold')], 'red')]
    end

    specify "non-listed tags pass through like normal text" do
      parse_to_nodes("Press <red><bold>ENTER</bold></red> or <bold><red>ESC</red></bold>", ['red']).should ==
        ["Press ", Node.new(["<bold>ENTER</bold>"], 'red'), " or <bold>", Node.new(["ESC"], 'red'), "</bold>"]
    end
  end

  describe "#reconstruct_from_nodes" do

    def reconstruct_from_nodes *args
      Xmlish.send(:reconstruct_from_nodes, *args)
    end

    specify "only string nodes" do
      reconstruct_from_nodes(["test"]).should == "test"
    end

    context "with null callbacks" do
      specify "single tag" do
        nodes = ["Press ", Node.new(["ENTER"], 'red')]
        callbacks = {'red' => nil}
        reconstruct_from_nodes(nodes).should == 'Press ENTER'
      end

      specify "nested tags" do
        nodes = ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red')]
        callbacks = {'red' => nil, 'bold' => nil}
        reconstruct_from_nodes(nodes, callbacks).should == 'Press ENTER'
      end

      specify "repeated tag" do
        nodes = ["Press ", Node.new(["ENTER"], 'red'), " or ", Node.new(["ESC"], 'red')]
        callbacks = {'red' => nil}
        reconstruct_from_nodes(nodes, callbacks).should == 'Press ENTER or ESC'
      end

      specify "repeated nested tags" do
        nodes = ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red'), " or ", Node.new([Node.new(["ESC"], 'bold')], 'red')]
        callbacks = {'red' => nil, 'bold' => nil}
        reconstruct_from_nodes(nodes, callbacks).should == 'Press ENTER or ESC'
      end
    end

    context "with modifying callbacks" do
      specify "single tag" do
        nodes = ["Press ", Node.new(["ENTER"], 'red')]
        callbacks = {'red' => lambda{|str|"$#{str}$"}}
        reconstruct_from_nodes(nodes, callbacks).should == 'Press $ENTER$'
      end

      specify "nested tags" do
        nodes = ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red')]
        callbacks = {
          'red' => lambda{|str|"$#{str}$"},
          'bold' => lambda{|str|"**#{str}**"}
        }
        reconstruct_from_nodes(nodes, callbacks).should == 'Press $**ENTER**$'
      end

      specify "repeated tag" do
        nodes = ["Press ", Node.new(["ENTER"], 'red'), " or ", Node.new(["ESC"], 'red')]
        callbacks = {'red' => lambda{|str|"$#{str}$"}}
        reconstruct_from_nodes(nodes, callbacks).should == 'Press $ENTER$ or $ESC$'
      end

      specify "repeated nested tags" do
        nodes = ["Press ", Node.new([Node.new(["ENTER"], 'bold')], 'red'), " or ", Node.new([Node.new(["ESC"], 'bold')], 'red')]
        callbacks = {
          'red' => lambda{|str|"$#{str}$"},
          'bold' => lambda{|str|"**#{str}**"}
        }
        reconstruct_from_nodes(nodes, callbacks).should == 'Press $**ENTER**$ or $**ESC**$'
      end
    end

  end

end
