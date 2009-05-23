require File.join(File.dirname(__FILE__), *%w[.. spec_helper])

module Blather
  describe 'Blather::Stanza' do
    it 'provides .next_id helper for generating new IDs' do
      proc { Blather::Stanza.next_id }.must_change 'Blather::Stanza.next_id'
    end

    it 'provides a handler registration mechanism' do
      class Registration < Stanza; register :handler_test, :handler, 'test:namespace'; end
      Registration.handler_heirarchy.must_include :handler_test
      Stanza.handler_list.must_include :handler_test
    end

    it 'can register based on handler' do
      class RegisterHandler < Stanza; register :register_handler; end
      Stanza.class_from_registration(:register_handler, nil).must_equal RegisterHandler
    end

    it 'can register based on given name' do
      class RegisterName < Stanza; register :handler, :registered_name; end
      Stanza.class_from_registration(:registered_name, nil).must_equal RegisterName
    end

    it 'can register subclass handlers' do
      class SuperClassRegister < Stanza; register :super_class; end
      class SubClassRegister < SuperClassRegister; register :sub_class; end
      SuperClassRegister.handler_heirarchy.wont_include :sub_class
      SubClassRegister.handler_heirarchy.must_include :super_class
    end

    it 'can import a node' do
      s = Stanza.import XMPPNode.new('foo')
      s.element_name.must_equal 'foo'
    end

    it 'provides an #error? helper' do
      s = Stanza.new('message')
      s.error?.must_equal false
      s.type = :error
      s.error?.must_equal true
    end

    it 'will generate a reply' do
      s = Stanza.new('message')
      s.from = f = JID.new('n@d/r')
      s.to = t = JID.new('d@n/r')

      r = s.reply
      r.object_id.wont_equal s.object_id
      r.from.must_equal t
      r.to.must_equal f
    end

    it 'convert to a reply' do
      s = Stanza.new('message')
      s.from = f = JID.new('n@d/r')
      s.to = t = JID.new('d@n/r')

      r = s.reply!
      r.object_id.must_equal s.object_id
      r.from.must_equal t
      r.to.must_equal f
    end

    it 'provides "attr_accessor" for id' do
      s = Stanza.new('message')
      s.id.must_be_nil
      s[:id].must_be_nil

      s.id = '123'
      s.id.must_equal '123'
      s[:id].must_equal '123'
    end

    it 'provides "attr_accessor" for to' do
      s = Stanza.new('message')
      s.to.must_be_nil
      s[:to].must_be_nil

      s.to = JID.new('n@d/r')
      s.to.wont_be_nil
      s.to.must_be_kind_of JID

      s[:to].wont_be_nil
      s[:to].must_equal 'n@d/r'
    end

    it 'provides "attr_accessor" for from' do
      s = Stanza.new('message')
      s.from.must_be_nil
      s[:from].must_be_nil

      s.from = JID.new('n@d/r')
      s.from.wont_be_nil
      s.from.must_be_kind_of JID

      s[:from].wont_be_nil
      s[:from].must_equal 'n@d/r'
    end

    it 'provides "attr_accessor" for type' do
      s = Stanza.new('message')
      s.type.must_be_nil
      s[:type].must_be_nil

      s.type = 'testing'
      s.type.wont_be_nil
      s[:type].wont_be_nil
    end

    it 'can be converted into an error by error name' do
      s = Stanza.new('message')
      err = s.as_error 'internal-server-error', 'cancel'
      err.name.must_equal :internal_server_error
    end
  end
end
