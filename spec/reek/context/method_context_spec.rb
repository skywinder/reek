require_relative '../../spec_helper'
require_relative '../../../lib/reek/context/method_context'

RSpec.describe Reek::Context::MethodContext do
  let(:method_context) { Reek::Context::MethodContext.new(nil, exp) }

  describe '#matches?' do
    let(:exp) { double('exp').as_null_object }

    before :each do
      expect(exp).to receive(:full_name).at_least(:once).and_return('mod')
    end

    it 'should recognise itself in a collection of names' do
      expect(method_context.matches?(['banana', 'mod'])).to eq(true)
      expect(method_context.matches?(['banana'])).to eq(false)
    end

    it 'should recognise itself in a collection of REs' do
      expect(method_context.matches?([/banana/, /mod/])).to eq(true)
      expect(method_context.matches?([/banana/])).to eq(false)
    end
  end

  describe '#envious_receivers' do
    let(:exp) { s(:def, :foo, s(:args, s(:arg, :bar)), nil) }

    it 'should ignore ivars as refs to self' do
      method_context.record_call_to s(:send, s(:ivar, :@cow), :feed_to)
      expect(method_context.envious_receivers).to be_empty
    end

    it 'should ignore explicit calls to self' do
      method_context.refs.record_reference_to :other
      method_context.record_call_to s(:send, s(:self), :thing)
      expect(method_context.envious_receivers).to be_empty
    end

    it 'should ignore implicit calls to self' do
      method_context.record_call_to s(:send, s(:lvar, :text), :each, s(:arglist))
      method_context.record_call_to s(:send, nil, :shelve, s(:arglist))
      expect(method_context.envious_receivers).to be_empty
    end

    it 'should record envious calls' do
      method_context.record_call_to s(:send, s(:lvar, :bar), :baz)
      expect(method_context.envious_receivers).to include(:bar)
    end
  end

  describe '#default_assignments' do
    def assignments_from(src)
      exp = Reek::Source::SourceCode.from(src).syntax_tree
      ctx = Reek::Context::MethodContext.new(nil, exp)
      ctx.default_assignments
    end

    context 'with no defaults' do
      it 'returns an empty hash' do
        src = 'def meth(arga, argb, &blk) end'
        expect(assignments_from(src)).to be_empty
      end
    end

    context 'with 1 default' do
      before :each do
        src = 'def meth(arga, argb=456, &blk) end'
        @defaults = assignments_from(src)
      end

      it 'returns the param-value pair' do
        expect(@defaults[0]).to eq [:argb, s(:int, 456)]
      end

      it 'returns the nothing else' do
        expect(@defaults.length).to eq(1)
      end
    end

    context 'with 2 defaults' do
      before :each do
        src = 'def meth(arga=123, argb=456, &blk) end'
        @defaults = assignments_from(src)
      end

      it 'returns both param-value pairs' do
        expect(@defaults[0]).to eq [:arga, s(:int, 123)]
        expect(@defaults[1]).to eq [:argb, s(:int, 456)]
      end

      it 'returns nothing else' do
        expect(@defaults.length).to eq(2)
      end
    end
  end
end
