# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent_application_container
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
require_relative '../../libraries/provider_shipyard_agent_application_container'

describe Chef::Provider::ShipyardAgentApplication::Container do
  let(:new_resource) do
    double(name: 'my_agent',
           install_type: 'test',
           docker_image: 'agent/agent',
           version: '1.2.3')
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#action_create' do
    let(:image) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:image)
        .and_return(image)
    end

    it 'pulls down the image from the Docker Index' do
      expect(image).to receive(:run_action).with(:pull)
      provider.action_create
    end
  end

  describe '#action_delete' do
    let(:image) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:image)
        .and_return(image)
    end

    it 'removes the Docker image' do
      expect(image).to receive(:run_action).with(:remove)
      provider.action_delete
    end
  end

  describe '#installed?' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:current_image)
        .and_return(current_image)
    end

    context 'without the agent installed' do
      let(:current_image) { double(tag: nil) }

      it 'returns false' do
        expect(provider.installed?).to eq(false)
      end
    end

    context 'with the agent installed' do
      let(:current_image) { double(tag: '1.2.3') }

      it 'returns true' do
        expect(provider.installed?).to eq(true)
      end
    end
  end

  describe '#version' do
    let(:current_image) { double(tag: tag) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:current_image)
        .and_return(current_image)
    end

    context 'without the agent installed' do
      let(:tag) { nil }

      it 'returns nil' do
        expect(provider.version).to eq(nil)
      end
    end

    context 'with the agent installed' do
      let(:tag) { '1.2.3' }

      it 'returns the version string' do
        expect(provider.version).to eq('1.2.3')
      end
    end
  end

  describe '#current_image' do
    it 'returns an instance of Chef::Resource::DockerImage' do
      expected = Chef::Resource::DockerImage
      expect(provider.send(:current_image)).to be_an_instance_of(expected)
    end
  end

  describe '#image' do
    it 'returns an instance of Chef::Resource::DockerImage' do
      expected = Chef::Resource::DockerImage
      expect(provider.send(:image)).to be_an_instance_of(expected)
    end
  end
end
