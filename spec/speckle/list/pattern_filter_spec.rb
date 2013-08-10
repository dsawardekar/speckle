require 'rake'
require 'spec_helper'
require 'speckle/list/pattern_filter'
require 'securerandom'

module Speckle
  module List

    describe 'PatternFilter' do

      before :each do 
        @filter = PatternFilter.new('^lorem')
      end

      it 'can be run' do
        expect(@filter).to respond_to(:run)
      end

      it 'returns an array on run' do
        result = @filter.run('foobar')

        expect(result).to be_kind_of(Array)
      end

      it 'returns empty array for a mismatched pattern', :a => true do
        result = @filter.run('foobar')
        expect(result).to be_empty
      end

      it 'returns passed filename if it matches pattern', :b => true do
        @filter = PatternFilter.new('pattern_filter')
        result = @filter.run(__FILE__)
        expect(result).to eq([__FILE__])
      end

      it 'returns empty array if file does not match pattern' do
        @filter = PatternFilter.new('loremipsumdolorsitamet')
        result = @filter.run("#{Dir.pwd}/spec/spec_helper.rb")
        expect(result).to eq([])
      end

      it 'returns empty array if it has content with invert flag', :d => true do
        @filter = PatternFilter.new('pattern_filter', true)
        result = @filter.run(__FILE__)
        expect(result).to eq([])
      end

      it 'returns array with passed item if file does not match pattern with invert flag' do
        @filter = FileContentFilter.new('loremipsumdolorsitamet', true)
        file = "#{Dir.pwd}/spec/spec_helper.rb"
        result = @filter.run(file)
        expect(result).to eq([file])
      end

    end

  end
end
