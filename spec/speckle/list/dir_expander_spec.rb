require 'spec_helper'
require 'speckle/list/dir_expander'

module Speckle
  module List

    describe 'DirExpander' do

      before :each do 
        @filter = DirExpander.new('**/*.riml')
      end

      it 'can be run' do
        expect(@filter).to respond_to(:run)
      end

      it 'returns an array of files on run' do
        result = @filter.run('spec')

        expect(result).to be_kind_of(Array)
        expect(result).to_not be_empty
      end

      it 'can returns an array of files that exist' do
        result = @filter.run('spec')

        result.each do |f|
          expect(File.exists?(f)).to be_true
        end
      end

    end

  end
end
