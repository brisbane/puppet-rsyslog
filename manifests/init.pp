# Class: rsyslog
# ===========================
#
# Full description of class rsyslog here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'rsyslog':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2019 Your name here, unless otherwise noted.


define rsyslog::conffile ( $source )
{

    
    file {"/etc/rsyslog.d/$name":
        owner => root,
        group => root,
        notify => Service[$rsyslog::servicename],
        source => $source
    }

}
define rsyslog::conffiles 
{
  
   $sources = split($name, '/')
   notify { "${sources[-1]}": }
   rsyslog::conffile  { "${sources[-1]}": source => $name }

}
class rsyslog ( $remotelogger = "", $additional_files=[], Boolean $configuresyslogtarget = false )
{


    ensure_packages (['rsyslog'])
    if ! empty($additional_files){
        rsyslog::conffiles{ $additional_files :}    
    }
    if $::os['family'] == 'RedHat' {
     
       $rhelver = "${facts['os']['release']['major']}"
       if "6" == "$rhelver" {
            $servicename = "rsyslog"

            file { '/etc/rsyslog.conf':
               source => "puppet:///modules/$name/rsyslog.conf.rhel${rhelver}",
               notify => Service["$servicename"],
               owner => root,
               group => root
            }
       }
       if "7" == "$rhelver" {
            $servicename = "rsyslog"

            file { '/etc/rsyslog.conf':
               source => "puppet:///modules/$name/rsyslog.conf.rhel${rhelver}",
               notify => Service["$servicename"],
               owner => root,
               group => root
            }
       }
       service { 'rsyslog':
           name => "$servicename",
           ensure => running,
           enable => true
       }
    
       if $remotelogger != "" and $::hostname != $remotelogger and $::fqdn != $remotelogger {
           file { "/etc/rsyslog.d/10-remotelogger.conf":
               notify => Service["$servicename"],
               content => epp("$name/remotelogger.conf.epp")
           }   
       }
    }
    else {

       notify {"This module $name does not support $::os['family']":}
    }
     file { "/etc/logrotate.d/iotop":
      source => "puppet:///modules/$name/iotop.logrotate"
   }
   
   if $::fqdn == $remotelogger or $::hostname == $remotelogger or $configuresyslogtarget {
       #gdpr override check 30 days remove regardless
       file { "/etc/cron.weekly/logremove":
           content => 'find /var/log/remote/ -mtime +30 -type f -exec rm {} \;\n',
           mode => "0770"
       }
       file { "/etc/logrotate.d/syslog.remote": 
           source  => "puppet:///modules/rsyslog/logrotate.syslog.remote",
           mode => "0644"
       }
       file { "/etc/rsyslog.d/target.conf": 
           source  => "puppet:///modules/rsyslog/rsyslog.d.target.conf",
           mode => "0644"
       }
   }  


}
