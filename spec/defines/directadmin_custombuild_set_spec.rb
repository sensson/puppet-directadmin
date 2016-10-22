require 'spec_helper'
describe 'directadmin::custombuild::set', :type => :define do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        let(:pre_condition) do
          'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
        end

        let(:title) do
          'foobar'
        end

        context "directadmin::custombuild::set define without parameters" do
          it 'fails' do
            expect { subject.call } .to raise_error(/Value can't be empty/)
          end
        end

        context "directadmin::custombuild::set define with value" do
          let(:params) {{
            :value => 'bar'
          }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('custombuild-set-foobar-bar').with_command('/usr/local/directadmin/custombuild/build set foobar bar') }
          it { is_expected.to contain_exec('custombuild-set-foobar-bar').with_unless('grep /usr/local/directadmin/custombuild/options.conf -e \'^foobar=bar\'') }
          it { is_expected.to contain_exec('custombuild-set-foobar-bar').that_requires('Class[directadmin::custombuild]') }
          it { is_expected.to contain_exec('custombuild-set-foobar-bar').that_comes_before('Class[directadmin::install]') }
        end
      end
    end 
  end
end