require 'spec_helper'
describe 'directadmin::directories', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::directories class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/usr/local/directadmin').with_ensure('directory') }
          it { is_expected.to contain_file('/usr/local/directadmin/plugins').with_ensure('directory') }
        end
      end
    end 
  end
end