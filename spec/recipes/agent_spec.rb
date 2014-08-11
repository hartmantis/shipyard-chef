# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: recipes/agent
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe 'shipyard::agent' do
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::Runner.new do |node|
      overrides.each { |k, v| node.set[k] = v }
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'default attributes' do
    it 'does not install Docker' do
      expect(chef_run).to_not include_recipe('docker')
    end
  end

  context 'a container-based install' do
    let(:overrides) { { shipyard: { agent: { install_type: :container } } } }

    it 'installs Docker' do
      expect(chef_run).to include_recipe('docker')
    end
  end
end
