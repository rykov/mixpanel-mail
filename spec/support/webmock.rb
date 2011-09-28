# Define a_get, a_post, etc and stub_get, stub_post, etc
[:delete, :get, :post, :put].each do |method|
  self.class.send(:define_method, "a_#{method}") do
    a_request(method, Mixpanel::Mail::ENDPOINT)
  end

  self.class.send(:define_method, "stub_#{method}") do
    stub_request(method, Mixpanel::Mail::ENDPOINT)
  end
end

# Allow to set expectations for a mixpanel request
def verify_mixpanel_requests(body = {}, num = 1, &block)
  stub_post
  block && block.call
  a_post.with(:body => body).should have_been_made.times(num)
end