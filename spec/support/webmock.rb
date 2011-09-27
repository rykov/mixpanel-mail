# Define a_get, a_post, etc and stub_get, stub_post, etc
[:delete, :get, :post, :put].each do |method|
  self.class.send(:define_method, "a_#{method}") do |path|
    a_request(method, Gemfury.endpoint + path)
  end

  self.class.send(:define_method, "stub_#{method}") do |path|
    stub_request(method, Gemfury.endpoint + path)
  end
end