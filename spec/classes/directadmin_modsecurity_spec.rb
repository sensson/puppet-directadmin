require 'spec_helper'
describe 'directadmin::modsecurity', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::modsecurity class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.not_to contain_directadmin__config__set('modsecurity') }
          it { is_expected.not_to contain_directadmin__config__set('modsecurity_ruleset') }
        end

        context "directadmin::modsecurity class with modsecurity enabled" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, modsecurity => true }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_directadmin__config__set('modsecurity') }
          it { is_expected.to contain_file_line('config-set-modsecurity-yes') }
        end

        context "directadmin::modsecurity class with modsecurity and modsecurity ruleset enabled" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, modsecurity => true, modsecurity_ruleset => true }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_directadmin__config__set('modsecurity_ruleset') }
          it { is_expected.to contain_file_line('config-set-modsecurity_ruleset-yes') }
        end

        context "directadmin::modsecurity class with modsecurity and modsecurity wordpress enabled" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, modsecurity => true, modsecurity_wordpress => true }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/directadmin/custombuild/custom/modsecurity/').with_ensure('directory') }
          it { is_expected.to contain_file('/usr/local/directadmin/custombuild/custom/modsecurity/conf/').with_ensure('directory') }
          it { is_expected.to contain_file('/usr/local/directadmin/custombuild/custom/modsecurity/conf/wordpress.conf') }
        end

      end
    end 
  end
end