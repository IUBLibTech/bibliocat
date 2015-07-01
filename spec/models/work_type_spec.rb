# Copyright 2014 Indiana University

describe WorkType do

  let!(:work_type) { FactoryGirl.create :work_type}

  describe "FactoryGirl" do
    let(:valid_work_type) { FactoryGirl.build :work_type }


    it "provides a valid work_type" do
      expect(valid_work_type).to be_valid
    end
  end

  it "should have the specified datastreams" do
    expect(work_type.datastreams.keys).to include "metadataSchema"
    expect(work_type.metadataSchema).to be_kind_of ActiveFedora::Datastream
  end

  it "should have the specified attributes" do
    expect(work_type).to respond_to(:metadata_schema)
    expect(work_type).to respond_to(:registered_name)
    expect(work_type).to respond_to(:display_name)
    expect(work_type).to respond_to(:is_type_of)
  end

end
