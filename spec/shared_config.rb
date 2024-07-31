require_relative 'spec_constants'

module SharedConfig
    def default_config(region)
      {
        region: region,
        public_key_id: SpecConstants::DUMMY_PUBLIC_KEY,
        private_key: SpecConstants::DUMMY_PRIVATE_KEY,
        sandbox: true
      }
    end
end  