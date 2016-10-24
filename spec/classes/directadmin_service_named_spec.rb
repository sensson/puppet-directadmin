require 'spec_helper'
describe 'directadmin::services::named', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:pre_condition) do
          'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
        end

        case facts[:operatingsystem]
        when 'RedHat', 'CentOS'
          named_path = '/etc/named.conf'
        when 'Debian', 'Ubuntu'
          named_path = '/etc/bind/named.conf.options'
        end

        context "directadmin::services::named class without parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('directadmin::services::named') }
          it { is_expected.to contain_exec('rewrite-named-config').with_refreshonly('true') }
          it { is_expected.to contain_exec('rewrite-named-config').with_unless('grep -c named /usr/local/directadmin/data/task.queue') }
        end

        context "directadmin::services::named class with allow transfer" do
          let(:params) {{
            :allow_transfer => '192.168.0.1'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file_line('named-enable-allow-transfer').with_ensure('present') }
          it { is_expected.to contain_file_line('named-enable-allow-transfer').with_path(named_path) }
          it { is_expected.to contain_file_line('named-enable-allow-transfer').with_line(/allow-transfer { 192.168.0.1; };/) }
        end

        context "directadmin::services::named class with also notify" do
          let(:params) {{
            :also_notify => '192.168.0.1'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file_line('named-enable-also-notify').with_ensure('present') }
          it { is_expected.to contain_file_line('named-enable-also-notify').with_path(named_path) }
          it { is_expected.to contain_file_line('named-enable-also-notify').with_line(/also-notify { 192.168.0.1; };/) }

          it { is_expected.to contain_file_line('named-enable-notify-setting').with_ensure('present') }
          it { is_expected.to contain_file_line('named-enable-notify-setting').with_path(named_path) }
          it { is_expected.to contain_file_line('named-enable-notify-setting').with_line(/notify yes;/) }
        end

      end
    end 
  end
end