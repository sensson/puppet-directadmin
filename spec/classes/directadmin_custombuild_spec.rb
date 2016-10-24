require 'spec_helper'
describe 'directadmin::custombuild', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::custombuild class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end
          
          custombuild_installer = 'http://files.directadmin.com/services/custombuild/2.0/custombuild.tar.gz'
          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('install-custombuild').with_command('rm -rf custombuild* && wget --no-check-certificate -O custombuild.tar.gz %s && tar xvzf custombuild.tar.gz' % [ custombuild_installer ])}
          it { is_expected.to contain_exec('install-custombuild').with_require('File[/usr/local/directadmin]') }
          it { is_expected.to contain_file('/usr/local/directadmin/custombuild/custom/').with_ensure('directory') }
        end
      end
    end 
  end
end