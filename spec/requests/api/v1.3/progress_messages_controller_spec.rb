describe "v1.3 - ProgressMessageRequests", :type => [:request, :v1x3] do
  let(:order) { create(:order) }
  let!(:order_item) { create(:order_item, :order_id => order.id, :portfolio_item_id => portfolio_item.id) }
  let(:portfolio_item) { create(:portfolio_item, :service_offering_ref => "123") }

  before do
    order.update_message("info", "test order progress_messages")
    order_item.update_message("info", "test order item progress_messages")
  end

  describe "v1.3" do
    context "GET /orders/:order_id/progress_messages" do
      it "lists progress messages" do
        get "#{api_version}/orders/#{order.id}/progress_messages", :headers => default_headers

        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].first['message']).to eq("test order progress_messages")
      end
    end

    context "GET /order_items/:order_item_id/progress_messages" do
      it "lists progress messages" do
        get "#{api_version}/order_items/#{order_item.id}/progress_messages", :headers => default_headers

        expect(response.content_type).to eq("application/json")
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['data'].first['message']).to eq("test order item progress_messages")
      end

      context "when the order item does not exist" do
        let(:order_item_id) { 0 }

        it "returns a 404" do
          get "#{api_version}/order_items/#{order_item_id}/progress_messages", :headers => default_headers

          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:not_found)
          expect(first_error_detail).to match(/Couldn't find OrderItem/)
        end
      end
    end
  end
end
