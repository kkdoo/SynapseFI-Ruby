module PayloadCreator

  def payload_for_single_transaction(node:, to_type:, to_id:, amount:, currency:, ip:,
                         **options)
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
    payload['extra']['asset']      = options[:asset] if options[:asset]
    payload['extra']['same_day']   = options[:same_day] if options[:same_day]
    payload['extra']['supp_id']    = options[:supp_id] if options[:supp_id]
    payload['extra']['note']       = options[:note] if options[:note]
    payload['extra']['process_on'] = options[:process_in] if options[:process_in]
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



  end
