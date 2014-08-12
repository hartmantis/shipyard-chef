# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent_service_container
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

require_relative '../spec_helper'
require_relative '../../libraries/provider_shipyard_agent_service_container'

describe Chef::Provider::ShipyardAgentService::Container do
  let(:new_resource) do
    double(name: 'my_agent',
           install_type: 'test',
           config_file: '/etc/default/agent',
           docker_image: 'shipyard/agent',
           :'created=' => true)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#action_create' do
    pending
  end

  describe '#action_delete' do
    pending
  end

  describe '#action_enable' do
    pending
  end

  describe '#action_disable' do
    pending
  end

  describe '#action_start' do
    let(:container) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:container)
        .and_return(container)
    end

    it 'runs the wrapped container' do
      expect(container).to receive(:run_action).with(:run)
      provider.action_start
    end
  end

  describe '#action_stop' do
    let(:container) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:container)
        .and_return(container)
    end

    it 'kills the wrapped container' do
      expect(container).to receive(:run_action).with(:kill)
      provider.action_stop
    end
  end

  describe '#created?' do
    it 'returns true (the create action does nothing for now)' do
      expect(provider.created?).to eq(true)
    end
  end

  describe '#container' do
    it 'returns an instance of Chef::Resource::DockerContainer' do
      expected = Chef::Resource::DockerContainer
      expect(provider.send(:container)).to be_an_instance_of(expected)
    end

    it 'names the container after the application' do
      expect(provider.send(:container).name).to eq('shipyard-agent')
    end

    it 'gives the container the correct base image' do
      expect(provider.send(:container).image).to eq('shipyard/agent')
    end

    it 'gives the container the detach order' do
      expect(provider.send(:container).detach).to eq(true)
    end

    it 'gives the container the correct port mapping' do
      expect(provider.send(:container).port).to eq('4500:4500')
    end

    it 'gives the container the correct environment variables' do
      expect(provider.send(:container).env_file).to eq('/etc/default/agent')
    end
  end
end
