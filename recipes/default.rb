#
# Cookbook Name:: chef-openvswitch
# Recipe:: default
#
# Copyright (C) 2014 Twiket Ltd
#
# All rights reserved - Do Not Redistribute
#

include_recipe "apt"
 


if platform?('ubuntu', 'debian')

  # obtain kernel version for kernel header
  # installation on ubuntu and debian
  kernel_ver = node['kernel']['release']
  package "linux-headers-#{kernel_ver}" do
    action :install
  end

end



%w{openvswitch-switch openvswitch-datapath-dkms openvswitch-test}.each do | pkg|
  apt_package pkg do
    action :install
  end
end

if platform?('ubuntu', 'debian')

  # NOTE:(mancdaz):sometimes the openvswitch module does not get reloaded
  # properly when openvswitch-datapath-dkms recompiles it.  This ensures
  # that it does

  begin
    if resources('package[openvswitch-datapath-dkms]')
      execute '/usr/share/openvswitch/scripts/ovs-ctl force-reload-kmod' do
        action :nothing
        subscribes :run, resources('package[openvswitch-datapath-dkms]'), :immediately
      end
    end
  rescue Chef::Exceptions::ResourceNotFound # rubocop:disable HandleExceptions
  end

end


service "openvswitch-switch" do
  supports :status => true, :start => true, :stop => true
  action [:enable, :start]
end
