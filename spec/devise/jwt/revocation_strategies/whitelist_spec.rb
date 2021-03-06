# frozen_string_literal: true

require 'spec_helper'

describe Devise::JWT::RevocationStrategies::Whitelist do
  include_context 'fixtures'

  subject(:strategy) { JwtWithWhitelistUser }

  let(:model) { JwtWithWhitelistUser }

  let(:user) { jwt_with_whitelist_user }

  let(:payload) do
    { 'jti' => '123', 'aud' => 'client1', 'exp' => Time.at(1_501_717_440) }
  end

  describe '#jwt_revoked?(payload, user)' do
    context 'when jti and aud in payload exist on jwt_whitelist' do
      before { user.whitelisted_jwts.create(payload) }

      it 'returns false' do
        expect(strategy.jwt_revoked?(payload, user)).to eq(false)
      end
    end

    context 'when jti and aud payload does not exist on jwt_whitelist' do
      it 'returns true' do
        expect(strategy.jwt_revoked?(payload, user)).to eq(true)
      end
    end
  end

  describe '#revoke_jwt(payload, user)' do
    before { user.whitelisted_jwts.create(payload) }

    it 'deletes matching jwt_whitelist record' do
      expect { strategy.revoke_jwt(payload, user) }
        .to(change { user.whitelisted_jwts.count }.by(-1))
    end
  end

  describe '#on_jwt_dispatch(token, payload)' do
    it 'creates whitelisted_jwt record from the payload' do
      jwt_with_whitelist_user.on_jwt_dispatch(:token, payload)

      expect(
        jwt_with_whitelist_user.whitelisted_jwts.exists?(payload)
      ).to eq(true)
    end
  end
end
