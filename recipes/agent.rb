# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Recipe:: agent
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

if node['shipyard']['agent']['install_type'] == :container
  include_recipe 'docker'
end

shipyard_agent_application 'local_agent' do
  install_type node['shipyard']['agent']['install_type']
  version node['shipyard']['agent']['version']
end

shipyard_agent_config 'defaults' do
  install_type node['shipyard']['agent']['install_type']
  url node['shipyard']['agent']['url']
  key node['shipyard']['agent']['key']
end

shipyard_agent_service 'agent' do
  install_type node['shipyard']['agent']['install_type']
end
