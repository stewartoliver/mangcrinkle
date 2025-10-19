require 'rails_helper'

RSpec.describe AdminNotificationJob, type: :job do
  let(:admin) { create(:user, :admin) }
  let(:order) { create(:order) }
  let(:notification_prefs) { create(:admin_notification_preference, user: admin, new_order_notifications: true) }

  before do
    allow(admin).to receive(:notification_preferences).and_return(notification_prefs)
    allow(AdminMailer).to receive(:new_order_notification).and_return(double(deliver_now: true))
  end

  describe '#perform' do
    it 'sends notification when admin wants notifications' do
      expect(AdminMailer).to receive(:new_order_notification).with(order, admin)
      
      described_class.perform_now(order.id, admin.id)
    end

    it 'does not send notification when admin does not want notifications' do
      notification_prefs.update!(new_order_notifications: false)
      
      expect(AdminMailer).not_to receive(:new_order_notification)
      
      described_class.perform_now(order.id, admin.id)
    end

    it 'handles missing order gracefully' do
      expect(Rails.logger).to receive(:error).with(/AdminNotificationJob failed: Order \d+ or Admin \d+ not found/)
      
      described_class.perform_now(999999, admin.id)
    end

    it 'handles missing admin gracefully' do
      expect(Rails.logger).to receive(:error).with(/AdminNotificationJob failed: Order \d+ or Admin \d+ not found/)
      
      described_class.perform_now(order.id, 999999)
    end
  end
end
