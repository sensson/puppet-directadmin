require 'spec_helper'
describe 'directadmin::services', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::services class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          case facts[:operatingsystem]
          when 'RedHat', 'CentOS'
            hasstatus = 'true'
          when 'Debian', 'Ubuntu'
            hasstatus = 'false'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_service('directadmin').with_hasstatus(hasstatus) }
          it { is_expected.to contain_service('exim').with_hasstatus(hasstatus) }
          it { is_expected.to contain_service('dovecot').with_hasstatus(hasstatus) }
          it { is_expected.to contain_service('httpd').with_hasstatus(hasstatus) }
          it { is_expected.to contain_service('named').with_hasstatus(hasstatus) }
        end

      end
    end 
  end
end