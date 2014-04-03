
bash "create integration bridge" do
  not_if("ovs-vsctl list-br | grep br-int")
  code <<-CODE
  ovs-vsctl add-br br-int
  CODE
end


#bash "testing" do
#  #not_if("ovs-vsctl list-br | grep br-int")
#  code <<-CODE
#  echo #{node["network"]["interfaces"]["eth0"]["addresses"].keys[1]} >>/tmp/data
#  CODE
#end

if node["network"]["interfaces"]["eth0"]["addresses"].keys[1] != nil
  ip = node["network"]["interfaces"]["eth0"]["addresses"].keys[1]

  bash "switch to bridge" do
    not_if "ip addr show dev eth0 | grep inet"
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

#route "default" do
#  attribute "value" # see attributes section below
#  gateway "10.0.0.20"
#  device "br-int"
#  action :action # see actions section below
#end
