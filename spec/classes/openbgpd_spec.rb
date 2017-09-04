# frozen_string_literal: true

require 'spec_helper'

describe 'openbgpd' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera
  let(:node) { 'openbgpd.example.com' }

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  let(:facts) do
    {}
  end

  # below is a list of the resource parameters that you can override.
  # By default all non-required parameters are commented out,
  # while all required parameters will require you to add a value
  let(:params) do
    {
      my_asn: 64_496,
      router_id: '192.0.2.2',
      networks4: ['192.0.2.0/25'],
      networks6: ['2001:DB8::/48'],
      failsafe_networks4: ['192.0.2.0/24'],
      failsafe_networks6: ['2001:DB8::/32'],
      #:failover_server => false,
      #:enable_advertisements => true,
      #:enable_advertisements_v4 => true,
      #:enable_advertisements_v6 => true,
      #:conf_file => "/usr/local/etc/bgpd.conf",
      #:package => "openbgpd",
      #:service => "openbgpd",
      #:enable => true,
      #:peers => {},
    }
  end

  # add these two lines in a single test block to enable puppet and hiera debug mode
  # Puppet::Util::Log.level = :debug
  # Puppet::Util::Log.newdestination(:console)
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'check default config' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('Openbgpd') }
        it { is_expected.to contain_package('openbgpd') }
        it do
          is_expected.to contain_file('/usr/local/etc/bgpd.conf').with(
            ensure: 'present',
            mode: '0400',
            require: 'Package[openbgpd]',
            notify: 'Service[openbgpd]'
          ).with_content(
            /AS 64496/
          ).with_content(
            /router-id 192.0.2.2/
          ).with_content(
            %r{network 192.0.2.0\/25}
          ).with_content(
            %r{network 2001:DB8::\/48}
          ).with_content(
            %r{network 192.0.2.0\/24}
          ).with_content(
            %r{network 2001:DB8::\/32}
          )
        end
        it do
          is_expected.to contain_service('openbgpd').with(
            ensure: true,
            enable: true
          )
        end
      end
      describe 'Change Defaults' do
        context 'my_asn' do
          before { params.merge!(my_asn: 64_497) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').with_content(
              /AS 64497/
            )
          end
        end
        context 'router_id' do
          before { params.merge!(router_id: '192.0.2.3') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').with_content(
              /router-id 192.0.2.3/
            )
          end
        end
        context 'networks4' do
          before { params.merge!(networks4: []) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 192.0.2.0\/25}
            )
          end
        end
        context 'networks6' do
          before { params.merge!(networks6: []) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 2001:DB8::\/48}
            )
          end
        end
        context 'failsafe_networks4' do
          before { params.merge!(failsafe_networks4: []) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 192.0.2.0\/24}
            )
          end
        end
        context 'failsafe_networks6' do
          before { params.merge!(failsafe_networks6: []) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 2001:DB8::\/32}
            )
          end
        end
        context 'failover_server' do
          before { params.merge!(failover_server: true) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 192.0.2.0\/25}
            ).without_content(
              %r{network 2001:DB8::\/48}
            ).with_content(
              %r{network 192.0.2.0\/24}
            ).with_content(
              %r{network 2001:DB8::\/32}
            )
          end
        end
        context 'enable_advertisements' do
          before { params.merge!(enable_advertisements: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 192.0.2.0\/25}
            ).without_content(
              %r{network 2001:DB8::\/48}
            ).without_content(
              %r{network 192.0.2.0\/24}
            ).without_content(
              %r{network 2001:DB8::\/32}
            )
          end
        end
        context 'enable_advertisements_v4' do
          before { params.merge!(enable_advertisements_v4: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').without_content(
              %r{network 192.0.2.0\/25}
            ).with_content(
              %r{network 2001:DB8::\/48}
            ).without_content(
              %r{network 192.0.2.0\/24}
            ).with_content(
              %r{network 2001:DB8::\/32}
            )
          end
        end
        context 'enable_advertisements_v6' do
          before { params.merge!(enable_advertisements_v6: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/usr/local/etc/bgpd.conf').with_content(
              %r{network 192.0.2.0\/25}
            ).without_content(
              %r{network 2001:DB8::\/48}
            ).with_content(
              %r{network 192.0.2.0\/24}
            ).without_content(
              %r{network 2001:DB8::\/32}
            )
          end
        end
        context 'conf_file' do
          before { params.merge!(conf_file: '/etc/foo.conf') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_file('/etc/foo.conf').with(
              ensure: 'present',
              mode: '0400',
              require: 'Package[openbgpd]',
              notify: 'Service[openbgpd]'
            )
          end
        end
        context 'package' do
          before { params.merge!(package: 'foo') }
          it { is_expected.to compile }
          it { is_expected.to contain_package('foo') }
        end
        context 'service' do
          before { params.merge!(service: 'foo') }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('foo').with(
              ensure: true,
              enable: true
            )
          end
        end
        context 'enable' do
          before { params.merge!(enable: false) }
          it { is_expected.to compile }
          it do
            is_expected.to contain_service('openbgpd').with(
              ensure: false,
              enable: false
            )
          end
        end
      end
      describe 'check bad type' do
        context 'my_asn' do
          before { params.merge!(my_asn: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'router_id' do
          before { params.merge!(router_id: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'router_id invalid ip address' do
          before { params.merge!(router_id: '1.1.1.1.1') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks4' do
          before { params.merge!(networks4: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks4 bad cidr size' do
          before { params.merge!(networks4: ['192.0.2.0/25', '192.0.2.0/111']) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks4 bad network' do
          before { params.merge!(networks4: ['1.192.0.2.0/32']) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks6' do
          before { params.merge!(networks6: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks6 bad cidr size' do
          before do
            params.merge!(networks6: ['2001:DB8::/48', '2001:DB8::/1111'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'networks6 bad network' do
          before do
            params.merge!(networks6: ['2001:DB8::/48', '20011:DB8::/128'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks4' do
          before { params.merge!(failsafe_networks4: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks4 bad cidr size' do
          before do
            params.merge!(failsafe_networks4: ['192.0.2.0/25', '192.0.2.0/111'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks4 bad network' do
          before { params.merge!(failsafe_networks4: ['1.192.0.2.0/32']) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks6' do
          before { params.merge!(failsafe_networks6: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks6 bad cidr size' do
          before do
            params.merge!(failsafe_networks6: ['2001:DB8::/48', '2001:DB8::/1111'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failsafe_networks6 bad network' do
          before do
            params.merge!(failsafe_networks6: ['2001:DB8::/48', '20011:DB8::/128'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v4' do
          before { params.merge!(rejected_v4: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v4 bad cidr size' do
          before do
            params.merge!(rejected_v4: ['192.0.2.0/25', '192.0.2.0/111'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v4 bad network' do
          before { params.merge!(rejected_v4: ['1.192.0.2.0/32']) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v6' do
          before { params.merge!(rejected_v6: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v6 bad cidr size' do
          before do
            params.merge!(rejected_v6: ['2001:DB8::/48', '2001:DB8::/1111'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'rejected_v6 bad network' do
          before do
            params.merge!(rejected_v6: ['2001:DB8::/48', '20011:DB8::/128'])
          end
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'failover_server' do
          before { params.merge!(failover_server: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable_advertisements' do
          before { params.merge!(enable_advertisements: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable_advertisements_v4' do
          before { params.merge!(enable_advertisements_v4: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable_advertisements_v6' do
          before { params.merge!(enable_advertisements_v6: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'conf_file' do
          before { params.merge!(conf_file: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'package' do
          before { params.merge!(package: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'service' do
          before { params.merge!(service: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'enable' do
          before { params.merge!(enable: 'foo') }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
        context 'peers' do
          before { params.merge!(peers: true) }
          it { expect { subject.call }.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end
