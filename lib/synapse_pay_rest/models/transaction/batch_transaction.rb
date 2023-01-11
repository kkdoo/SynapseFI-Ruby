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

      def payload_for_batch_create(transactions:, **options)
        {
          'transactions' => transactions.map{|transaction| payload_for_create(**transaction)}
        }
      end

      def multiple_from_response(node, response)
        raise 'not impletemented yet'
      end
    end
  end
end
