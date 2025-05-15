include Rails.application.routes.url_helpers

RSpec.shared_examples "missing parameters error response" do |http_method, action, params = {}|
  it "returns 400 Bad Request with missing parameters error" do
    send(http_method, action, params: params)
    expect(response).to have_http_status(:bad_request)
    expect(JSON.parse(response.body)["errors"]).to eq("Missing parameters")
  end
end

RSpec.shared_examples "missing template error response" do |http_method, action, params = {}|
  it "returns 406 Not Acceptable with missing template error" do
    send(http_method, action, params: params, headers: { "Accept" => "text/html" })
    expect(response).to have_http_status(:not_acceptable)
    expect(JSON.parse(response.body)["errors"]).to eq("Invalid Accept header or missing JSON response")
  end
end

RSpec.shared_examples "internal server error response" do |http_method, action, params = {}|
  it "returns 500 Internal Server Error with generic error message" do
    send(http_method, action, params: params)
    expect(response).to have_http_status(:internal_server_error)
    expect(JSON.parse(response.body)["errors"]).to eq("Interal server error")
  end
end

RSpec.shared_examples "routing error response" do
  it "returns 404 Not Found for unmatched routes" do
    expect { get "/this-route-does-not-exist" }.to raise_error(ActionController::RoutingError)
  end
end
