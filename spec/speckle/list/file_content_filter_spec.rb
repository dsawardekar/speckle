require 'rake'
require 'spec_helper'
require 'speckle/list/file_content_filter'
require 'securerandom'

module Speckle
  module List

    describe 'FileContentFilter' do

      before :each do 
        @filter = FileContentFilter.new('custom_content')
      end

      it 'can be run' do
        expect(@filter).to respond_to(:run)
      end

      it 'returns an array on run' do
        result = @filter.run(__FILE__)

        expect(result).to be_kind_of(Array)
      end

      it 'returns empty array for non existant file' do
        result = @filter.run(SecureRandom.uuid())
        expect(result).to be_empty
      end

      it 'returns passed file if it has content' do
        result = @filter.run(__FILE__)
        expect(result).to eq([__FILE__])
      end

      it 'returns empty array if file does not match pattern' do
        @filter = FileContentFilter.new('loremipsumdolorsitamet')
        result = @filter.run("#{Dir.pwd}/spec/spec_helper.rb")
        expect(result).to eq([])
      end

      it 'returns empty array if it has content with invert flag' do
        @filter = FileContentFilter.new('focus', true)
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
