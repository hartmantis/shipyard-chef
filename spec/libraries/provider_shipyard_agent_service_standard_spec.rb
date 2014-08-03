# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent_service_standard
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
require_relative '../../libraries/provider_shipyard_agent_service_standard'

describe Chef::Provider::ShipyardAgentService::Standard do
  let(:new_resource) do
    double(name: 'my_agent',
           install_type: 'test',
           cookbook_name: :shipyard,
           :'created=' => true)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#action_create' do
    let(:init_script) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:init_script)
        .and_return(init_script)
    end

    it 'creates the init script' do
      expect(init_script).to receive(:run_action).with(:create)
      provider.action_create
    end
  end

  describe '#action_delete' do
    let(:init_script) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:action_stop)
      allow_any_instance_of(described_class).to receive(:action_disable)
      allow_any_instance_of(described_class).to receive(:init_script)
        .and_return(init_script)
    end

    it 'stops the service' do
      expect_any_instance_of(described_class).to receive(:action_stop)
      provider.action_delete
    end

    it 'disables the service' do
      expect_any_instance_of(described_class).to receive(:action_disable)
      provider.action_delete
    end

    it 'deletes the init script' do
      expect(init_script).to receive(:run_action).with(:delete)
      provider.action_delete
    end
  end

  [:enable, :disable, :start, :stop].each do |act|
    describe "#action_#{act}" do
      let(:service) { double(run_action: true) }

      before(:each) do
        allow_any_instance_of(described_class).to receive(:service)
          .and_return(service)
      end

      it "#{act}s the service" do
        expect(service).to receive(:run_action).with(act)
        provider.send(:"action_#{act}")
      end
    end
  end

  describe '#created?' do
    let(:exist) { nil }

    before(:each) do
      allow(::File).to receive(:exist?).with('/etc/init/shipyard-agent')
        .and_return(exist)
    end

    context 'existing init script on filesystem' do
      let(:exist) { true }

      it 'returns true' do
        expect(provider.created?).to eq(true)
      end
    end

    context 'non-existent init script on filesystem' do
      let(:exist) { false }

      it 'returns false' do
        expect(provider.created?).to eq(false)
      end
    end
  end

  describe '#service' do
    it 'returns a Service instance' do
      expected = Chef::Resource::Service
      expect(provider.send(:service)).to be_an_instance_of(expected)
    end
  end

  describe '#init_script' do
    it 'returns a Template instance' do
      expected = Chef::Resource::Template
      expect(provider.send(:init_script)).to be_an_instance_of(expected)
    end

    it 'sets up the correct source cookbook' do
      expect(provider.send(:init_script).cookbook).to eq('shipyard')
    end

    it 'sets up the correct source path' do
      expected = 'upstart/shipyard-agent.conf.erb'
      expect(provider.send(:init_script).source).to eq(expected)
    end

    it 'sets up the correct destination path' do
      expected = '/etc/init/shipyard-agent'
      expect(provider.send(:init_script).name).to eq(expected)
    end
  end

  describe '#init_dir' do
    it 'returns "/etc/init" (since we only support Ubuntu for now)' do
      expect(provider.send(:init_dir)).to eq('/etc/init')
    end
  end

  describe '#init_system' do
    it 'returns ":upstart" (since we only support Ubuntu for now)' do
      expect(provider.send(:init_system)).to eq(:upstart)
    end
  end
end
