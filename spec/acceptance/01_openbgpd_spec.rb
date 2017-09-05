# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openbgpd class' do
  context 'defaults' do
    pp = 'class {\'::openbgpd\': }'
    it 'work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'clean run' do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe service('openbgpd') do
      it { is_expected.to be_running }
    end
  end
  context 'basic IPv4 peer' do
    pp = <<-EOF
    class { '::openbgpd':
      my_asn => 64496,
      router_id => '192.0.2.1',
      networks4 => [ '192.0.2.0/24'],
      peers => {
        '64497' => {
          'addr4' => ['192.0.2.2'],
          'desc'  => 'TEST Network'
          }
      }
    }
      EOF
    it 'work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'clean work with no errors' do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe service('openbgpd') do
      it { is_expected.to be_running }
    end
    describe process('bgpd') do
      its(:user) { is_expected.to eq 'openbgpd' }
      it { is_expected.to be_running }
    end
    describe port(179) do
      it { is_expected.to be_listening }
    end
    describe command('bgpctl show sum') do
      its(:stdout) do
        is_expected.to match(
          %r{TEST NETWORK\s64496.*4}
        )
      end
      its(:stdout) do
        is_expected.not_to match(
          %r{TEST NETWORK\s64496.*6}
        )
      end
    end
  end
  context 'basic IPv6 peer' do
    pp = <<-EOF
    class { '::openbgpd':
      my_asn => 64496,
      router_id => '192.0.2.1',
      networks6 => [ '2001:DB8::/48'],
      peers => {
        '64497' => {
          'addr6' => ['2001:DB8::2'],
          'desc'  => 'TEST Network'
          }
      }
    }
      EOF
    it 'work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'clean work with no errors' do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe service('openbgpd') do
      it { is_expected.to be_running }
    end
    describe process('bgpd') do
      its(:user) { is_expected.to eq 'openbgpd' }
      it { is_expected.to be_running }
    end
    describe port(179) do
      it { is_expected.to be_listening }
    end
    describe command('bgpctl show sum') do
      its(:stdout) do
        is_expected.not_to match(
          %r{TEST NETWORK\s64496.*4}
        )
      end
      its(:stdout) do
        is_expected.to match(
          %r{TEST NETWORK\s64496.*6}
        )
      end
    end
  end
  context 'basic IPv6 & IPv4 peers' do
    pp = <<-EOF
    class { '::openbgpd': 
      my_asn => 64496,
      router_id => '192.0.2.1',
      networks4 => [ '192.0.2.0/24'],
      networks6 => [ '2001:DB8::/48'],
      peers => {
        '64497' => {
          'addr4' => ['192.0.2.2'],
          'addr6' => ['2001:DB8::2'],
          'desc'  => 'TEST Network'
          }
      }
    }
      EOF
    it 'work with no errors' do
      apply_manifest(pp, catch_failures: true)
    end
    it 'clean work with no errors' do
      expect(apply_manifest(pp, catch_failures: true).exit_code).to eq 0
    end
    describe service('openbgpd') do
      it { is_expected.to be_running }
    end
    describe process('bgpd') do
      its(:user) { is_expected.to eq '_bgpd' }
      it { is_expected.to be_running }
    end
    describe port(179) do
      it { is_expected.to be_listening }
    end
    describe command('bgpctl show sum') do
      its(:stdout) do
        is_expected.to match(
          %r{TEST NETWORK\s64496.*4}
        )
      end
      its(:stdout) do
        is_expected.to match(
          %r{TEST NETWORK\s64496.*6}
        )
      end
    end
  end
end
