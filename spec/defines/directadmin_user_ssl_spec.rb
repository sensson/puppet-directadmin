require 'spec_helper'
describe 'directadmin::user_ssl', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:pre_condition) do
          'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
        end

        context "directadmin::user_ssl define without parameters" do
          let(:title) do
            'foobar'
          end

          it 'fails' do
            expect { subject.call } .to raise_error(/user can't be empty/)
          end
        end

        context "directadmin::user_ssl define without sslcert" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :user => 'admin'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/sslcert can't be empty/)
          end
        end

        context "directadmin::user_ssl define without sslkey" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :user => 'admin',
            :sslcert => 'CERT'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/sslkey can't be empty/)
          end
        end

        context "directadmin::user_ssl with values" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :user => 'admin',
            :sslcert => 'CERT',
            :sslkey => 'KEY'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cert') }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cert').with_content('CERT') }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.key') }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.key').with_content('KEY') }
        end

        context "directadmin::user_ssl with ca certificate" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :user => 'admin',
            :sslcert => 'CERT',
            :sslkey => 'KEY',
            :sslca => 'CA'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cacert') }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cacert').with_content('CA') }
        end

        context "directadmin::user_ssl with pem certificate" do
          let(:title) do
            'foobar'
          end

          let(:params) {{
            :user => 'admin',
            :sslcert => 'CERT',
            :sslkey => 'KEY',
            :sslpem => 'PEM'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cert.combined') }
          it { is_expected.to contain_file('/usr/local/directadmin/data/users/admin/domains/foobar.cert.combined').with_content('PEM') }
        end
      end
    end
  end
end
