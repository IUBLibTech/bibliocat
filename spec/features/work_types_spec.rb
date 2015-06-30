require 'spec_helper'

describe 'WorkType features' do
  #let!(:test_work_type) { FactoryGirl.create :work_type}

  it "can create new work types" do
    visit work_types_path
    click_button 'New type'
    assert_equal current_path, new_work_type_path
    fill_in 'Registered name', with: 'FeatureType'
    fill_in 'Display name', with: 'Feature work type'
    fill_in 'Is type of', with: 'BiblioWork'
    click_button 'Save type'
    assert_equal current_path, work_types_path
  end

  it "can edit work types" do
  end

  it "can attach metadata schema to work type" do
  end

  
end
