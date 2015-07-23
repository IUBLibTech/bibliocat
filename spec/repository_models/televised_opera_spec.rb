# Generated via
#  `rails generate bibliocat:work TelevisedOpera`
require 'rails_helper'

describe TelevisedOpera do
  it 'should have metadata methods matching the configuration' do
    work = TelevisedOpera.new

    # Descriptive metadata from vocabularies
    work_type = work.human_readable_type
    vocabs =  I18n.t work_type + '.fields'

    vocabs.each do |vocab, fields|
      fields.each do |key, value|
        expect(work.respond_to?(key))
      end
    end
    expect(!work.respond_to?(:not_a_real_method))

  end
end
