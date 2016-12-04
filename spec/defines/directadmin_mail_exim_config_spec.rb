require 'spec_helper'
describe 'directadmin::mail::exim::config', :type => :define do
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

        context "directadmin::mail::exim::config define without parameters" do
          it 'fails' do
            expect { subject.call } .to raise_error(/file must be set/)
          end
        end

        context "directadmin::mail::exim::config define with /etc in a file" do
          let (:params) {{
            :file => '/etc/exim.strings.conf.custom'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/file should be specified without/)
          end
        end

        context "directadmin::mail::exim::config define without a value" do
          let (:params) {{
            :file => 'exim.strings.conf.custom'
          }}

          it 'fails' do
            expect { subject.call } .to raise_error(/value must be set/)
          end
        end

        context "directadmin::mail::exim::config define with parameters" do
          let(:params) {{
            :file => 'exim.strings.conf.custom',
            :value => 'RBL'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/etc/exim.strings.conf.custom') }
          it { is_expected.to contain_file_line('exim-set-exim.strings.conf.custom-foobar-RBL') }
          it { is_expected.to contain_file_line('exim-set-exim.strings.conf.custom-foobar-RBL').with_path('/etc/exim.strings.conf.custom') }
          it { is_expected.to contain_file_line('exim-set-exim.strings.conf.custom-foobar-RBL').with_line('foobar==RBL') }
          it { is_expected.to contain_file_line('exim-set-exim.strings.conf.custom-foobar-RBL').that_requires('File[/etc/exim.strings.conf.custom]') }
          it { is_expected.to contain_file_line('exim-set-exim.strings.conf.custom-foobar-RBL').that_notifies('Service[exim]') }
        end

      end
    end 
  end
end