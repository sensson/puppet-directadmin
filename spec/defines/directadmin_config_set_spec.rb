require 'spec_helper'
describe 'directadmin::config::set', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:pre_condition) do
          'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
        end

        context "directadmin::config::set define without parameters" do
          let(:title) do
            'foobar'
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/Value can't be empty/)
          end
        end

        context "directadmin::config::set define with value" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :value => 'bar'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_directadmin__config__set('foobar') }
          it { is_expected.to contain_file_line('config-set-foobar-bar').with_line('foobar=bar') }
          it { is_expected.to contain_file_line('config-set-foobar-bar').that_requires('Class[directadmin::install]') }
          it { is_expected.to contain_file_line('config-set-foobar-bar').that_notifies('Service[directadmin]') }
        end

        context "directadmin::config::set define with nameserver settings" do
          let(:title) do
            'ns1'
          end

          let(:params) {{
            :value => 'bar'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_directadmin__config__set('ns1') }
          it { is_expected.to contain_file_line('config-set-ns1-bar') }
          it { is_expected.to contain_file_line('config-set-ns1-bar').that_requires('Class[directadmin::install]') }
          it { is_expected.to contain_file_line('config-set-admin-reseller-ns1-bar').with_line('ns1=bar')}
          it { is_expected.to contain_file_line('config-set-admin-user-ns1-bar').with_line('ns1=bar')}
        end
      end
    end 
  end
end