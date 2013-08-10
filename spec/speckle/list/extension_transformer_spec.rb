require 'rake'
require 'spec_helper'
require 'speckle/list/extension_transformer'

module Speckle
  module List

    describe 'ExtensionTransformer' do

      before :each do 
        @filter = ExtensionTransformer.new('vim')
      end

      it 'can be run' do
        expect(@filter).to respond_to(:run)
      end

      it 'returns an array on run' do
        result = @filter.run('foo.riml')

        expect(result).to be_kind_of(Array)
        expect(result).to_not be_empty
      end

      it 'changes the extension on run' do
        result = @filter.run('foo.riml')
        expect(result).to eq(['foo.vim'])
      end

    end

  end
end
