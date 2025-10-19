require 'rails_helper'

RSpec.describe OrderConfirmationJob, type: :job do
  let(:order) { create(:order) }

  before do
    allow(CustomerMailer).to receive(:order_confirmation).and_return(double(deliver_now: true))
  end

  describe '#perform' do
    it 'sends order confirmation email' do
      expect(CustomerMailer).to receive(:order_confirmation).with(order)
      
      described_class.perform_now(order.id)
    end

    it 'handles missing order gracefully' do
      expect(Rails.logger).to receive(:error).with(/Order \d+ not found/)
      
      described_class.perform_now(999999)
    end

    it 're-raises other exceptions' do
      allow(CustomerMailer).to receive(:order_confirmation).and_raise(StandardError, 'Test error')
      
      expect { described_class.perform_now(order.id) }.to raise_error(StandardError, 'Test error')
    end
  end
end
