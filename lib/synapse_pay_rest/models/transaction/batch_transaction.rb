module SynapsePayRest
  # Represents a batch transaction record and holds methods for constructing batch transaction instances
  # from API calls. This is built on top of the SynapsePayRest::Transactions class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  #

  class BatchTransaction < Transaction
    attr_reader :node, :trans, :error_code, :http_codee, :success, :page_count

    class << self
      # Creates a new batch transaction in the API belonging to the provided node and
      # returns a batch transaction instance from the response data.
      #
      # @param node [SynapsePayRest::BaseNode] node to which the transaction belongs
      #
      # @raise [SynapsePayRest::Error] if HTTP error or invalid argument format
      #
      # @return [SynapsePayRest::BatchTrans]
      #

      def create(node:, transactions:, **options)
        raise ArgumentError, 'cannot create a batch transaction with an UnverifiedNode' if node.is_a?(UnverifiedNode)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)

        response = node.user.client.trans.create_batch(
          user_id: node.user.id,
          node_id: node.id,
          payload: payload_for_batch_create(transactions: transactions, **options)
        )
        from_response(node, response)
      end

      # Creates a Batch Transaction from a response hash.
      #
      # @note Shouldn't need to call this directly.
      #
      # @todo convert the nodes and users in response into User/Node objects
      def from_response(node, response)
        args = {
          node:          node,
          error_code:    response['error_code'],
          http_code:     response['http_code'],
          success:       response['success'],
          page_count:    response['page_count'],
          trans_count:   response['trans_count'],
          trans:         response['trans'].map{|tx_response| Transaction.from_response(node, tx_response)},
        }
        self.new(**args)
      end

      private

      def payload_for_create_transaction(to_type:, to_id:, amount:, currency:, ip:, **options)
        payload = {
          'to' => {
            'type' => to_type,
            'id' => to_id
          },
          'amount' => {
            'amount' => amount,
            'currency' => currency
          },
          'extra' => {
            'ip' => ip
          }
        }
        # optional payload fields
        payload['extra']['asset']      = options[:asset]      if options[:asset]
        payload['extra']['same_day']   = options[:same_day]   if options[:same_day]
        payload['extra']['supp_id']    = options[:supp_id]    if options[:supp_id]
        payload['extra']['note']       = options[:note]       if options[:note]
        payload['extra']['process_on'] = options[:process_in] if options[:process_in]
        payload['extra']['group_id']   = options[:group_id]   if options[:group_id]
        other = {}
        other['attachments'] = options[:attachments] if options[:attachments]
        payload['extra']['other'] = other if other.any?
        fees = []
        # deprecated fee flow
        fee = {}
        fee['fee']  = options[:fee_amount] if options[:fee_amount]
        fee['note'] = options[:fee_note] if options[:fee_note]
        fee_to = {}
        fee_to['id'] = options[:fee_to_id] if options[:fee_to_id]
        fee['to'] = fee_to if fee_to.any?
        fees << fee if fee.any?
        # new fee flow
        fees = options[:fees] if options[:fees]
        payload['fees'] = fees if fees.any?
        payload
      end


      def payload_for_batch_create(transactions:, **options)
        {
          'transactions' => transactions.map{|transaction| payload_for_create_transaction(**transaction)}
        }
      end

      def multiple_from_response(node, response)
        raise 'not impletemented yet'
      end
    end
  end
end
