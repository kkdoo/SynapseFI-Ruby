module SynapsePayRest
    class IcDepositUsNode < BaseNode
      class << self
        private
        
        def payload_for_create(nickname:, **options)
          args = {
            type: 'IC-DEPOSIT-US',
            nickname: nickname
          }.merge(options)
          super(**args)
        end
      end
    end
end  