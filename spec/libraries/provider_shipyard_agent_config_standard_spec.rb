# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent_standard
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
require_relative '../../libraries/provider_shipyard_agent_config_standard'

describe Chef::Provider::ShipyardAgentConfig::Standard do
  let(:new_resource) do
    double(name: 'my_agent',
           install_type: :standard,
           :'created=' => true,
           source: 'conf.erb',
           path: '/etc/ship.conf',
           url: 'http://1.2.3.4',
           key: 'abcd')
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#action_create' do
    let(:conf_dir) { double(recursive: true, run_action: true) }
    let(:conf_file) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:conf_dir)
        .and_return(conf_dir)
      allow_any_instance_of(described_class).to receive(:conf_file)
        .and_return(conf_file)
    end

    it 'creates the config dir recursively' do
      expect(conf_dir).to receive(:recursive).with(true)
      expect(conf_dir).to receive(:run_action).with(:create)
      provider.action_create
    end

    it 'creates the config file' do
      expect(conf_file).to receive(:run_action).with(:create)
      provider.action_create
    end
  end

  describe '#action_delete' do
    let(:conf_dir) { double(run_action: true, only_if: true) }
    let(:conf_file) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:conf_dir)
        .and_return(conf_dir)
      allow_any_instance_of(described_class).to receive(:conf_file)
        .and_return(conf_file)
    end

    it 'deletes the config file' do
      expect(conf_file).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'deletes the config directory if empty' do
      expect(conf_dir).to receive(:only_if)
      expect(conf_dir).to receive(:run_action).with(:delete)
      provider.action_delete
    end
  end

  describe '#created?' do
    let(:created) { nil }

    before(:each) do
      allow(::File).to receive(:exist?).with('/etc/ship.conf')
        .and_return(created)
    end

    context 'an existing config file' do
      let(:created) { true }

      it 'returns true' do
        expect(provider.created?).to eq(true)
      end
    end

    context 'a non-existing config file' do
      let(:created) { false }

      it 'returns false' do
        expect(provider.created?).to eq(false)
      end
    end
  end

  describe '#conf_file' do
    it 'returns a Template instance' do
      expected = Chef::Resource::Template
      expect(provider.send(:conf_file)).to be_an_instance_of(expected)
    end

    it 'uses the path specified by the resource' do
      expect(provider.send(:conf_file).name).to eq('/etc/ship.conf')
    end

    it 'uses the URL and key specified by the resource' do
      expected = { url: 'http://1.2.3.4', key: 'abcd' }
      expect(provider.send(:conf_file).variables).to eq(expected)
    end
  end

  describe '#conf_dir' do
    it 'returns a Directory instance' do
      expected = Chef::Resource::Directory
      expect(provider.send(:conf_dir)).to be_an_instance_of(expected)
    end

    it 'uses the path specified by the resource' do
      expect(provider.send(:conf_dir).name).to eq('/etc')
    end
  end
end
