require "rails_helper"

RSpec.describe V2::LinkSetsController do
  let(:content_id) { SecureRandom.uuid }
  let(:document) { FactoryGirl.create(:document, content_id: content_id) }

  before do
    FactoryGirl.create(:draft_edition, document: document)
    stub_request(:any, /content-store/)
  end

  describe "bulk_links" do
    context "called without providing content_ids parameter" do
      it "is unsuccessful" do
        post :bulk_links, params: {}
        expect(response.status).to eql 422
      end
    end

    context "called with empty content_ids parameter" do
      it "is unsuccessful" do
        post :bulk_links, params: { content_ids: [] }
        expect(response.status).to eql 422
      end
    end

    context "with content_ids" do
      it "is successful" do
        post :bulk_links, params: { content_ids: [SecureRandom.uuid] }
        expect(response.status).to eql 200
      end
    end
  end

  describe "get_linked" do
    context "called without providing fields parameter" do
      it "is unsuccessful" do
        get :get_linked, params: { content_id: content_id, link_type: "topic" }
        expect(response.status).to eq(422)
      end
    end

    context "called with empty fields parameter" do
      it "is unsuccessful" do
        get :get_linked, params: { content_id: content_id, link_type: "topic", fields: [] }

        expect(response.status).to eq(422)
      end
    end

    context "called without providing link_type parameter" do
      before do
        get :get_linked, params: { content_id: content_id, fields: ["content_id"] }
      end

      it "is unsuccessful" do
        expect(response.status).to eq(422)
      end
    end

    context "for an existing edition" do
      before do
        get :get_linked, params: { content_id: content_id, link_type: "topic", fields: ["content_id"] }
      end

      it "is successful" do
        expect(response.status).to eq(200)
      end
    end

    context "for a non-existing edition" do
      before do
        get :get_linked, params: { content_id: SecureRandom.uuid, link_type: "topic", fields: ["content_id"] }
      end

      it "is unsuccessful" do
        expect(response.status).to eq(404)
      end
    end
  end
end
