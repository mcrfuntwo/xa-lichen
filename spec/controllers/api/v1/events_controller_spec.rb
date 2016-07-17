require 'rails_helper'

describe Api::V1::EventsController, type: :controller do
  include Randomness
  include ResponseJson

  it 'can open transactions' do
    rand_times.map { create(:user) }.each do |um|
      len = Transaction.all.count
      post(:create, event_type: 'transaction_open', transaction_open_event: { user_id: um.id })

      evt = TransactionOpenEvent.last
      expect(evt).to_not be_nil
      expect(evt.user).to eql(um)
      expect(evt.event).to eql(Event.last)
      expect(evt.event.public_id).to_not be_nil

      expect(Transaction.all.count).to eql(len + 1)
      expect(Transaction.last).to_not be_nil
      expect(Transaction.last.user).to eql(evt.user)
      expect(Transaction.last.status).to eql(Transaction::STATUS_OPEN)
      
      expect(response).to be_success
      expect(response_json).to eql(encode_decode(url: api_v1_event_path(id: evt.event.public_id)))
    end
  end

  it 'can show transaction open events' do
    rand_times.map { create(:user) }.each do |um|
      rand_times.map { create(:transaction_open_event, user: um, event: create(:event, event_type: 'transaction_open')) }.each do |toem|
        get(:show, id: toem.event.public_id)
        
        expect(response).to be_success
        expect(response_json).to eql(encode_decode(EventSerializer.serialize_transaction_open(toem.event)))
      end
    end
  end

  it 'can close transactions' do
    rand_array_of_uuids.each do |public_id|
      tr = create(:transaction, public_id: public_id)
      post(:create, event_type: 'transaction_close', transaction_close_event: { transaction_public_id: public_id })

      evt = TransactionCloseEvent.last

      expect(evt).to_not be_nil
      expect(evt.transact).to eql(tr)
      expect(Transaction.find(tr.id).status).to eql(Transaction::STATUS_CLOSED)

      expect(response).to be_success
      expect(response_json).to eql(encode_decode(url: api_v1_event_path(id: evt.event.public_id)))
    end
  end

  it 'can show transaction close events' do
    rand_times.map { create(:transaction) }.each do |tr|
      rand_times.map { create(:transaction_close_event, transact: tr, event: create(:event, event_type: 'transaction_close')) }.each do |tcem|
        get(:show, id: tcem.event.public_id)
        
        expect(response).to be_success
        expect(response_json).to eql(encode_decode(EventSerializer.serialize_transaction_close(tcem.event)))
      end
    end
  end

  it 'can push invoices' do
    rand_array_of_models(:transaction).each do |trm|
      rand_array_of_uuids.each do |document_id|
        post(:create, event_type: 'invoice_push', invoice_push_event: { transaction_public_id: trm.public_id, document_public_id: document_id })

        evt = InvoicePushEvent.last

        expect(evt).to_not be_nil
        expect(evt.event).to eql(Event.last)
        expect(evt.transact).to eql(trm)
        expect(evt.transaction_public_id).to eql(trm.public_id)
        expect(evt.document_public_id).to eql(document_id)

        expect(response).to be_success
        expect(response_json).to eql(encode_decode(url: api_v1_event_path(id: evt.event.public_id)))
      end
    end
  end

  it 'can show invoice push events' do
    rand_times.map { create(:transaction) }.each do |trm|
      rand_times.map { create(:invoice_push_event, transact: trm, event: create(:event, event_type: 'invoice_push')) }.each do |ipem|
        get(:show, id: ipem.event.public_id)
        
        expect(response).to be_success
        expect(response_json).to eql(encode_decode(EventSerializer.serialize_invoice_push(ipem.event)))
      end
    end
  end
end