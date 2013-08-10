require 'spec_helper'
require 'speckle/list/absolute_path_transformer'

module Speckle
  module List

    describe 'AbsolutePathTransformer' do

      before :each do 
        @filter = AbsolutePathTransformer.new
      end

      it 'can be run' do
        expect(@filter).to respond_to(:run)
      end

      it 'can converts path to list with path' do
        result = @filter.run('foo')
        expect(result).to be_kind_of(Array)
        expect(result).to eq(["#{Dir.pwd}/foo"])
      end

    end

  end
end
