require 'java'

import org.jruby.compiler.impl.SkinnyMethodAdapter

begin
  import org.objectweb.asm.MethodVisitor
  import org.objectweb.asm.Opcodes
rescue # jarjar renames things, so we try the renamed version
  import "jruby.objectweb.asm.MethodVisitor"
  import "jruby.objectweb.asm.Opcodes"
end

class MockMethodVisitor
  attr_accessor :calls

  def initialize
    @calls = []
  end

  def method_missing(name, *args)
    @calls << [name, args]
  end
end

describe "SkinnyMethodAdapter" do  
  it "supports all JVM opcodes" do
    keyword_opcodes = [] # gather opcodes that are named after keywords separately
    insn_opcodes = Opcodes.constants.select do |c|
      case c
      when /ACC_/, # access modifiers
           /V1_/, # version identifiers
           /T_/, # type identifiers
           /F_/, # framing hints
           /H_/, # method handles
           /ASM/ # ASM version stuff
        false
      when "DOUBLE", "FLOAT", "INTEGER", "LONG", "NULL", "TOP", "UNINITIALIZED_THIS"
        false
      when "GOTO", "RETURN", "INSTANCEOF", "NEW"
        false
      when "INVOKEDYNAMIC_OWNER"
        false
      else
        true
      end
    end
    
    insn_opcodes.each do |opcode|
      opcode = opcode.downcase
      SkinnyMethodAdapter.instance_methods.should include(opcode)
    end
    
    SkinnyMethodAdapter.instance_methods.should include("go_to")
    SkinnyMethodAdapter.instance_methods.should include("voidreturn")
    SkinnyMethodAdapter.instance_methods.should include("instance_of")
    SkinnyMethodAdapter.instance_methods.should include("newobj")
  end
end
