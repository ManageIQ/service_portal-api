describe "IconsRequests", :type => :request do
  let(:icon_id) { 1 }
  let(:api_instance) { double }
  let(:topological_inventory) do
    class_double("TopologicalInventory")
      .as_stubbed_const(:transfer_nested_constants => true)
  end

  let(:topology_service_offering_icon) do
    TopologicalInventoryApiClient::ServiceOfferingIcon.new(
      :id         => icon_id.to_s,
      :source_ref => "src",
      :data       => "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 100 100\"><defs><style>.cls-1{fill:#d71e00}.cls-2{fill:#c21a00}.cls-3{fill:#fff}.cls-4{fill:#eaeaea}</style></defs><title>Logo</title><g id=\"Layer_1\" data-name=\"Layer 1\"><circle class=\"cls-1\" cx=\"50\" cy=\"50\" r=\"50\" transform=\"rotate(-45 50 50)\"/><path class=\"cls-2\" d=\"M85.36 14.64a50 50 0 0 1-70.72 70.72z\"/><path d=\"M31 31.36a1.94 1.94 0 0 1-3.62-.89.43.43 0 0 1 .53-.44 3.32 3.32 0 0 0 2.81.7.43.43 0 0 1 .28.63z\"/><path class=\"cls-3\" d=\"M77.63 44.76C77.12 41.34 73 21 66.32 21c-2.44 0-4.59 3.35-6 6.88-.44 1.06-1.23 1.08-1.63 0-1.45-3.72-2.81-6.88-5.41-6.88-9.94 0-5.44 24.18-14.28 24.18-4.57 0-5.37-10.59-5.5-14.72 2.19.65 3.3-1 3.55-2.61a.63.63 0 0 0-.48-.72 3.36 3.36 0 0 0-3 .89h-6.26a1 1 0 0 0-.68.28l-.53.53h-3.89a.54.54 0 0 0-.38.16l-3.95 3.95a.54.54 0 0 0 .38.91h11.45c.6 6.26 1.75 22 16.42 17.19l-.32 5-1.44 22.42a1 1 0 0 0 1 1h4.9a1 1 0 0 0 1-1l-.61-23.33-.15-5.81c6-2.78 9-5.66 16.19-6.75-1.59 2.62-2.05 6.87-2.06 8-.06 6 2.55 8.74 5 13.22L63.73 78a1 1 0 0 0 .89 1.32h4.64a1 1 0 0 0 .93-.74L74 62.6c-4.83-7.43 1.83-15.31 3.41-17a1 1 0 0 0 .22-.84zM31 31.36a1.94 1.94 0 0 1-3.62-.89.43.43 0 0 1 .53-.44 3.32 3.32 0 0 0 2.81.7.43.43 0 0 1 .28.63z\"/><path class=\"cls-4\" d=\"M46.13 51.07c-14.67 4.85-15.82-10.93-16.42-17.19H18.65l2.1 2.12a1 1 0 0 0 .68.28h6c0 5.8 1.13 20.2 14 20.2a31.34 31.34 0 0 0 4.42-.35zM50.41 49.36l.15 5.81a108.2 108.2 0 0 0 14-4.54 19.79 19.79 0 0 1 2.06-8c-7.16 1.07-10.18 3.95-16.21 6.73z\"/></g></svg>"
    )
  end

  let(:topo_ex) { Catalog::TopologyError.new("kaboom") }

  before do
    allow(topological_inventory).to receive(:call).and_yield(api_instance)
    allow(api_instance).to receive(:show_service_offering_icon).and_return(topology_service_offering_icon)
  end

  describe "#show" do
    context "when we have to hit topology for the icon data" do
      it "reaches out to topology to get the icon" do
        expect(api_instance).to receive(:show_service_offering_icon).with(topology_service_offering_icon.id).and_return(topology_service_offering_icon)

        get "#{api}/icons/#{icon_id}", :headers => default_headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq "image/svg+xml"
      end
    end
  end

  describe "#icon_bulk_query" do
    context "when requesting multiple icons" do
      before do
        post "#{api}/icons", :headers => default_headers, :params => { :ids => "1,2,3" }
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns one per id requested" do
        expect(json.size).to eq 3
      end
    end

    context  "when requesting multiple icons with duplicates" do
      before do
        post "#{api}/icons", :headers => default_headers, :params => { :ids => "1,1,1" }
      end

      it "returns a 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns only one icon" do
        expect(json.size).to eq 1
      end
    end

    context "when an icon doesn't exist" do
      before do
        allow(api_instance).to receive(:show_service_offering_icon).and_raise(topo_ex)
      end

      it "throws not found" do
        post "#{api}/icons", :headers => default_headers, :params => { :ids => "1,2,2" }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
