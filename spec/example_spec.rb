require 'spec_helper'

describe Xmlish do

  describe ".parse" do
    specify "repeated nested tags" do
      template = "Press <red><bold>ENTER</bold></red> or <bold><red>ESC</red></bold>"
      callbacks = {
        'red' => lambda{|str|"$#{str}$"},
        'bold' => lambda{|str|"**#{str}**"}
      }
      Xmlish.parse(template, callbacks).should == 'Press $**ENTER**$ or **$ESC$**'
    end

    specify "more complex repeated nested tags" do
      template = "Press <red><u><</u><bold><downcase>ENTER</downcase></bold><u>></u></red> or <bold><red>ESC</red></bold>"
      callbacks = {
        'red' => lambda{|str|"$#{str}$"},
        'bold' => lambda{|str|"**#{str}**"},
        'u' => lambda{|str|"_#{str}_"},
        'downcase' => lambda{|str|str.downcase},
      }
      Xmlish.parse(template, callbacks).should == 'Press $_<_**enter**_>_$ or **$ESC$**'
    end

    specify "plain text callbacks" do
      template = "Press <red>ENTER</red> or <red>ESC</red>"
      callbacks = {
        'red' => lambda{|str|"$#{str}$"},
        'text' => lambda{|str|"(#{str.upcase})"},
      }
      Xmlish.parse(template, callbacks).should == '(PRESS )$(ENTER)$( OR )$(ESC)$'
    end

    it "should leave tags without callback intact" do
      template = "Press <red><bold>ENTER</bold></red> or <bold><red>ESC</red></bold>"
      callbacks = {
        'red' => lambda{|str|"$#{str}$"}
      }
      Xmlish.parse(template, callbacks).should == 'Press $<bold>ENTER</bold>$ or <bold>$ESC$</bold>'
    end

    it "should tolerate bad syntax in tags without callbacks" do
      template = "Press <red>ENTER</bold></red> or <bold><red>ESC</red></penguins></>"
      callbacks = {
        'red' => lambda{|str|"$#{str}$"}
      }
      Xmlish.parse(template, callbacks).should == 'Press $ENTER</bold>$ or <bold>$ESC$</penguins></>'
    end
  end

  describe ".walk" do
    specify "building output in application" do
      template = "Press <red>ENTER</red> or <red>ESC</red>"
      output = []
      callbacks = {
        'red' => lambda{|str|
          output << "{red-on}"
          str.call
          output << "{red-off}"
        },
        'text' => lambda{|str|
          output << str.call.upcase
        },
      }
      Xmlish.walk(template, callbacks)
      output.join("").should == 'PRESS {red-on}ENTER{red-off} OR {red-on}ESC{red-off}'
    end
  end

end
