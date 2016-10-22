require 'spec_helper'
describe 'directadmin::install', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::install class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_exec('directadmin-set-pre-install').with('cwd' => '/root') }
          it { is_expected.to contain_exec('directadmin-set-pre-install').with('command' => 'echo 1 > /root/.preinstall') }
          it { is_expected.to contain_exec('directadmin-set-pre-install').with('creates' => '/root/.preinstall') }
          it { is_expected.to contain_exec('directadmin-set-pre-install').that_comes_before('Exec[directadmin-installer]') }
          it { is_expected.to contain_exec('directadmin-download-installer').with('cwd' => '/root') }
          it { is_expected.to contain_exec('directadmin-download-installer').with('command' => 'wget -O setup.sh --no-check-certificate http://www.directadmin.com/setup.sh && chmod +x /root/setup.sh') }
          it { is_expected.to contain_exec('directadmin-download-installer').with('creates' => '/root/setup.sh') }
          it { is_expected.to contain_exec('directadmin-download-installer').with('cwd' => '/root') }
          it { is_expected.to contain_exec('directadmin-installer').with('cwd' => '/root') }
          it { is_expected.to contain_exec('directadmin-installer').with_command('echo 2.0 > /root/.custombuild && /root/setup.sh %i %i %s %s' % [ 1234, 123456, facts[:fqdn], 'eth0' ]) }

          case facts[:osfamily]
          when 'RedHat'
            if facts[:operatingsystemmajrelease].to_i >= 6
              it { is_expected.to contain_package('perl-ExtUtils-MakeMaker') }
              it { is_expected.to contain_package('perl-Digest-SHA') }
              it { is_expected.to contain_package('perl-Net-DNS') }
              it { is_expected.to contain_package('perl-NetAddr-IP') }
              it { is_expected.to contain_package('perl-Archive-Tar') }
              it { is_expected.to contain_package('perl-IO-Zlib') }
              it { is_expected.to contain_package('perl-Mail-SPF') }
              it { is_expected.to contain_package('perl-IO-Socket-INET6') }
              it { is_expected.to contain_package('perl-IO-Socket-SSL') }
              it { is_expected.to contain_package('perl-Mail-DKIM') }
              it { is_expected.to contain_package('perl-DBI') }
              it { is_expected.to contain_package('perl-Encode-Detect') }
              it { is_expected.to contain_package('perl-HTML-Parser') }
              it { is_expected.to contain_package('perl-HTML-Tagset') }
              it { is_expected.to contain_package('perl-Time-HiRes') }
              it { is_expected.to contain_package('perl-libwww-perl') }
              it { is_expected.to contain_package('perl-ExtUtils-Embed') }
            end
            if facts[:operatingsystemmajrelease].to_i >= 7
              it { is_expected.to contain_package('perl-Sys-Syslog') }
            end
          when 'Debian'
            it { is_expected.to contain_package('libarchive-any-perl') }
            it { is_expected.to contain_package('libhtml-parser-perl') }
            it { is_expected.to contain_package('libnet-dns-perl') }
            it { is_expected.to contain_package('libnetaddr-ip-perl') }
            it { is_expected.to contain_package('libhttp-date-perl') }
          end
        end

        context "directadmin::install class with lan enabled" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, lan => true }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_file('/root/.lan').with_content('1') }
          it { is_expected.to contain_file('/root/.lan').with_ensure('file') }
          it { is_expected.to contain_file('/root/.lan').that_comes_before('Exec[directadmin-installer]') }
        end

      end
    end 
  end
end