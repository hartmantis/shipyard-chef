# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Recipe:: host
#
# Copyright 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['shipyard']['host']['install_type'].to_s
when 'container'
  include_recipe 'docker'
when 'standard'
  include_recipe 'python'
  include_recipe 'redis'
  include_recipe 'nodejs'
  include_recipe 'hipache'
end

if [:container, 'container'].include?(node['shipyard']['host']['install_type'])
  include_recipe 'docker'
else

# Create shipyard resource instance
