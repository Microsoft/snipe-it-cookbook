#
# Cookbook:: snipe-it-cookbook
# Recipe:: requirements
#
# The MIT License (MIT)
#
# Copyright:: 2018, Microsoft
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

%w(database smtp).each do |credential|
  unless node['snipeit'][credential]['username'] && node['snipeit'][credential]['password']
    node.default['snipeit'][credential]['username'] = chef_vault_item('snipeit', credential)['username']
    node.default['snipeit'][credential]['password'] = chef_vault_item('snipeit', credential)['password']
  end
end

unless node['snipeit']['php']['app_key']
  node.default['snipeit']['php']['app_key'] = chef_vault_item('snipeit', 'app_key')['key']
end

directory '/var/www' do
  user node['nginx']['user']
  group node['nginx']['group']
end

git node['snipeit']['path'] do
  repository 'git://github.com/snipe/snipe-it'
  revision node['snipeit']['version']
  action :sync
  user node['nginx']['user']
  group node['nginx']['group']
end

template node['snipeit']['path'] + '/.env' do
  source 'env.erb'
  user node['nginx']['user']
  group node['nginx']['group']
  sensitive true
end
