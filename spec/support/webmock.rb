# Define a_get, a_post, etc and stub_get, stub_post, etc
[:delete, :get, :post, :put].each do |method|
  self.class.send(:define_method, "a_#{method}") do
    a_request(method, Mixpanel::Mail::ENDPOINT)
  end

  self.class.send(:define_method, "stub_#{method}") do
    stub_request(method, Mixpanel::Mail::ENDPOINT)
  end
end