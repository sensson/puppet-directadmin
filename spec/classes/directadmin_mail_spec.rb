require 'spec_helper'
describe 'directadmin::mail', :type => :class do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "directadmin::mail class without parameters" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456 }'
          end

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('directadmin::mail') }

          it { is_expected.to contain_file('/etc/virtual/limit').with_content('200') }
          it { is_expected.to contain_file('/etc/virtual/limit').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_file('/etc/virtual/limit_unknown').with_content('0') }
          it { is_expected.to contain_file('/etc/virtual/limit_unknown').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_file('/etc/virtual/user_limit').with_content('0') }
          it { is_expected.to contain_file('/etc/virtual/user_limit').that_requires('Exec[directadmin-installer]') }

          it { is_expected.to contain_file('/var/www/html/webmail').with_target('/var/www/html/roundcube') }
          it { is_expected.to contain_file('/var/www/html/webmail').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_file_line('httpd-alias-default-webmail').with_line('Alias /webmail /var/www/html/roundcube') }
          it { is_expected.to contain_file_line('httpd-alias-default-webmail').that_requires('Exec[directadmin-installer]') }
          it { is_expected.to contain_directadmin__config__set('webmail_link') }
          it { is_expected.to contain_file_line('config-set-webmail_link-roundcube') }

          it { is_expected.to contain_cron('exim-sa-update').with_ensure('absent') }
          it { is_expected.to contain_file_line('exim-set-primary-hostname').with_line('primary_hostname = %s' % [facts[:fqdn]]) }

          # By default we don't manage rbls
          it { is_expected.not_to contain_file('/etc/virtual/use_rbl_domains') }

          # By default we don't install php-imap
          it { is_expected.not_to contain_exec('directadmin-download-php-imap') }
          it { is_expected.not_to contain_exec('directadmin-install-php-imap') }
          it { is_expected.not_to contain_exec('libc-client2007e-dev') }
        end

        context "directadmin::mail class with php imap" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, php_imap => true, }'
          end


          it { is_expected.to contain_exec('directadmin-download-php-imap') }
          it { is_expected.to contain_exec('directadmin-install-php-imap') }

          if facts[:operatingsystem] =~ /^(Debian|Ubuntu)$/
            if facts[:operatingsystemmajrelease].to_i >= 7
              it { is_expected.to contain_package('libc-client2007e-dev') }
            end
          end
        end

        context "directadmin::mail class with spamassassin updates" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, sa_updates => true, }'
          end

          it { is_expected.to contain_cron('exim-sa-update').with_ensure('present') }
        end

        context "directadmin::mail class with rbl management" do
          let(:pre_condition) do
            'class { "::directadmin": clientid => 1234, licenseid => 123456, default_rbl => true, }'
          end

          it { is_expected.to contain_file('/etc/virtual/use_rbl_domains').with_ensure('link') }
        end
      end
    end 
  end
end