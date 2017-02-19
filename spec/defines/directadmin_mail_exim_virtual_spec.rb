require 'spec_helper'
describe 'directadmin::mail::exim::virtual', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:title) do
          'foobar'
        end

        let(:pre_condition) do
          'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
        end

        context "directadmin::mail::exim::virtual define without parameters" do
          it 'fails' do
            expect { subject.call } .to raise_error(/file must be set/)
          end
        end

        context "directadmin::mail::exim::virtual define with /etc in a file" do
          let (:params) {{
            :file => '/etc/virtual/skip_rbl_hosts_ip'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/file should be specified without/)
          end
        end

        context "directadmin::mail::exim::virtual define without a value" do
          let (:params) {{
            :file => 'skip_rbl_hosts_ip'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/value must be set/)
          end
        end

        context "directadmin::mail::exim::virtual define with parameters" do
          let(:params) {{
            :file => 'skip_rbl_hosts_ip',
            :value => '127.0.0.1'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/virtual/skip_rbl_hosts_ip') }
          it { is_expected.to contain_file('/etc/virtual/skip_rbl_hosts_ip').with_require('Exec[directadmin-installer]') }
          it { is_expected.to contain_file_line('exim-set-skip_rbl_hosts_ip-127.0.0.1') }
          it { is_expected.to contain_file_line('exim-set-skip_rbl_hosts_ip-127.0.0.1').with_path('/etc/virtual/skip_rbl_hosts_ip') }
          it { is_expected.to contain_file_line('exim-set-skip_rbl_hosts_ip-127.0.0.1').with_line('127.0.0.1') }
          it { is_expected.to contain_file_line('exim-set-skip_rbl_hosts_ip-127.0.0.1').that_requires('File[/etc/virtual/skip_rbl_hosts_ip]') }
          it { is_expected.to contain_file_line('exim-set-skip_rbl_hosts_ip-127.0.0.1').that_notifies('Service[exim]') }
        end

      end
    end 
  end
end