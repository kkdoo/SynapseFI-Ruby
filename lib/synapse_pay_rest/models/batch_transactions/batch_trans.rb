module SynapsePayRest
  # Represents a batch transaction record and holds methods for constructing batch transaction instances
  # from API calls. This is built on top of the SynapsePayRest::Transactions class and
  # is intended to make it easier to use the API without knowing payload formats
  # or knowledge of REST.
  #

  class BatchTrans
    # @!attribute [rw] node
    #   @return [SynapsePayRest::Node] the node to which the transaction belongs
    attr_reader :node, :id, :client_id, :client_name, :created_on

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

      def create(node:, payload:)
        raise ArgumentError, 'cannot create a batch transaction with an UnverifiedNode' if node.is_a?(UnverifiedNode)
        raise ArgumentError, 'node must be a type of BaseNode object' unless node.is_a?(BaseNode)

        response = node.user.client.trans.create_batch_trans(
          user_id: node.user.id,
          node_id: node.id,
          payload: payload
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
          trans:         response['trans'],

        }
        self.new(**args)
      end

      private

      def multiple_from_response(node, response)
        return [] if response.empty?
        response.map { |trans_data| from_response(node, trans_data) }
      end
    end

    # @note Do not call directly. Use BatchTrans.create or other class
    #   method to instantiate via API action.
    def initialize(**options)
      options.each { |key, value| instance_variable_set("@#{key}", value) }
    end


    # Checks if two Transaction instances have same id (different instances of same record).
    def ==(other)
      other.instance_of?(self.class) && !id.nil? && id == other.id
    end
  end
end
