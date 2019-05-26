module ObjectDetectApi
  URL = 'vision/v2.0/analyze'
  SUBSCRIPTION_KEY = '9201aa054c0e4f6caf04b461d2044e73'

  class << self
    def object_tags(image)
      ApiSetup.post_call_azure(
        endpoint_name: URL,
        request_params: { 'visualFeatures' => 'Description,Tags' },
        request_body: image,
        request_type: ApiSetup::REQUEST_TYPE_OS, 
        subscription_key: SUBSCRIPTION_KEY,
      )
    end
  end
end