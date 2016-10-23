require 'spec_helper'
describe 'directadmin::mail::spamassassin::score', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:title) do
          'foobar'
        end

        context "directadmin::mail::spamassassin::score define without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file_line('enable-foobar-1') }
          it { is_expected.to contain_file_line('enable-foobar-1').with_line('score foobar 1') }
          it { is_expected.to contain_file_line('enable-foobar-1').that_notifies('Service[exim]') }
          it { is_expected.to contain_file_line('enable-foobar-1').that_requires('Exec[directadmin-installer]') }
        end

        context "directadmin::mail::spamassassin::score define with a score specified" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, admin_password => \'hashed\' }'
          end

          let(:params) {{
            :score => '10',
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file_line('enable-foobar-10') }
          it { is_expected.to contain_file_line('enable-foobar-10').with_line('score foobar 10') }
          it { is_expected.to contain_file_line('enable-foobar-10').that_notifies('Service[exim]') }
          it { is_expected.to contain_file_line('enable-foobar-10').that_requires('Exec[directadmin-installer]') }
        end

      end
    end 
  end
end