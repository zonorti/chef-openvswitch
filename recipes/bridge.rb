
bash "create integration bridge" do
  not_if("ovs-vsctl list-br | grep br-int")
  code <<-CODE
  ovs-vsctl add-br br-int
  CODE
end


if node["network"]["interfaces"]["eth0"]["addresses"].keys[1] != nil
  ip = node["network"]["interfaces"]["eth0"]["addresses"].keys[1]

  bash "switch to bridge" do
    user "root"
    cwd "/tmp"
    code <<-EOH
    ip link set br-int up
    ip addr flush dev eth0;
    ip addr add #{ip}/#{node["network"]["interfaces"]["eth0"]["addresses"][ip]["prefixlen"]} dev br-int;
    ovs-vsctl add-port br-int eth0;
    ip route add default via #{node["network"]["default_gateway"]} dev br-int;
    EOH
  end
end

