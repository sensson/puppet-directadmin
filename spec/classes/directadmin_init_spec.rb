require 'spec_helper'
describe 'directadmin', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin class with parameters" do
          let(:params) {{
            :clientid => '1234',
            :licenseid => '123456'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('directadmin') }
          it { is_expected.to contain_class('directadmin::directories') }
          it { is_expected.to contain_class('directadmin::custombuild') }
          it { is_expected.to contain_class('directadmin::install') }
          it { is_expected.to contain_class('directadmin::update') }
          it { is_expected.to contain_class('directadmin::services') }
          it { is_expected.to contain_class('directadmin::resources') }

          # Directories. Referenced in directadmin::directories
          # Filename: directadmin_custombuild_directories.rb
          it { is_expected.to contain_file('/usr/local/directadmin').with_ensure('directory') }
          it { is_expected.to contain_file('/usr/local/directadmin/plugins').with_ensure('directory') }
        end

        context "directadmin class without parameters" do
          it 'fails' do
            expect { subject.call } .to raise_error(/The client ID/)
          end
        end

      end
    end 
  end
end