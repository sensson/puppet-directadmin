require 'spec_helper'
describe 'directadmin::mail::spamassassin::config', :type => :define do
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

        context "directadmin::mail::spamassassin::config define without parameters" do
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('99-foobar') }
          it { is_expected.to contain_file('99-foobar').with_ensure('present') }
          it { is_expected.to contain_file('99-foobar').with_path('/etc/mail/spamassassin/99-foobar.cf') }
          it { is_expected.to contain_file('99-foobar').with_content('') }
          it { is_expected.to contain_file('99-foobar').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_file('99-foobar').that_notifies('Service[exim]') }
        end

        context "directadmin::mail::spamassassin::config define with parameters" do
          let(:params) {{
            :order => '40',
            :content => 'bar'
          }}
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('40-foobar') }
          it { is_expected.to contain_file('40-foobar').with_ensure('present') }
          it { is_expected.to contain_file('40-foobar').with_path('/etc/mail/spamassassin/40-foobar.cf') }
          it { is_expected.to contain_file('40-foobar').with_content('bar') }
          it { is_expected.to contain_file('40-foobar').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_file('40-foobar').that_notifies('Service[exim]') }
        end

      end
    end 
  end
end