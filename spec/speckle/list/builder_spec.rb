require 'rake'
require 'spec_helper'
require 'speckle/list/builder'
require 'speckle/list/absolute_path_transformer'
require 'speckle/list/dir_expander'
require 'speckle/list/extension_transformer'
require 'speckle/list/file_content_filter'
require 'speckle/list/pattern_filter'
require 'securerandom'

module Speckle
  module List

    describe 'Builder' do

      before :each do 
        @builder = Builder.new
      end

      it 'can be built' do
        expect(@builder).to respond_to(:build)
      end

      it 'can build list of source files from directory', :a => true do
        builder = Builder.new
        builder.add_source 'spec'
        builder.add_filter DirExpander.new('**/*_spec.riml')
        builder.add_filter FileContentFilter.new('class', false)
        builder.add_filter PatternFilter.new('matcher')
        builder.add_filter AbsolutePathTransformer.new
        builder.add_filter ExtensionTransformer.new('riml')

        result = builder.build
        result.each do |f|
          expect(File.exists?(f)).to be_true
        end
        #puts result
      end

    end

  end
end
