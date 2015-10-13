require 'rails_helper'

RSpec.describe DraftContentItem do
  subject { FactoryGirl.build(:draft_content_item) }

  def verify_new_attributes_set
    expect(described_class.first.title).to eq("New title")
  end

  describe 'validations' do
    before do
      create(:live_content_item, content_id: '123', base_path: '/foo')
    end
    it 'validates base_path' do
      draft = build(:draft_content_item, content_id: '123', base_path: '/bar')
      expect(draft).not_to be_valid
    end
  end

  let(:new_attributes) {
    {
      content_id: content_id,
      title: "New title",
    }
  }

  it_behaves_like Replaceable
  it_behaves_like DefaultAttributes
end
