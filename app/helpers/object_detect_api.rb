module ObjectDetectApi
  URL = 'vision/v2.0/analyze'
  SUBSCRIPTION_KEY = '0f0c7750313442659facc6bbd506ab08'

  class << self
    def image_tags(image)
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