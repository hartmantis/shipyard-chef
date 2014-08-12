# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/resource_shipyard_agent_application
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
require_relative '../../libraries/resource_shipyard_agent_application'

describe Chef::Resource::ShipyardAgentApplication do
  [:install_type, :source, :docker_image, :version].each do |i|
    let(i) { nil }
  end
  let(:resource) do
    r = Chef::Resource::ShipyardAgentApplication.new('my_agent', nil)
    r.install_type(install_type)
    r.source(source)
    r.docker_image(docker_image)
    r.version(version)
    r
  end

  describe '#initialize' do
    it 'defaults to the GitHub binary install provider' do
      expected = Chef::Provider::ShipyardAgentApplication::Standard
      expect(resource.instance_variable_get(:@provider)).to eq(expected)
    end

    it 'defaults to the "create" action' do
      expect(resource.instance_variable_get(:@action)).to eq(:create)
    end

    it 'defaults the installed state to false' do
      expect(resource.installed).to eq(false)
      expect(resource.installed?).to eq(false)
    end
  end

  describe '#install_type' do
    let(:override) { nil }
    let(:resource) do
      r = super()
      r.install_type(override)
      r
    end

    context 'no override provided' do
      it 'defaults to a GitHub binary install' do
        expect(resource.install_type).to eq(:standard)
      end
    end

    context 'a valid override provided' do
      let(:override) { 'container' }

      it 'returns the override symbolized' do
        expect(resource.install_type).to eq(:container)
      end

      it 'sets the corresponding provider' do
        expected = Chef::Provider::ShipyardAgentApplication::Container
        expect(resource.provider).to eq(expected)
        expect(resource.instance_variable_get(:@provider)).to eq(expected)
      end
    end

    context 'an invalid override provided' do
      let(:install_type) { 'monkeys' }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#source' do
    let(:override) { nil }
    let(:resource) do
      r = super()
      r.source(override)
      r
    end

    context 'no override provided' do
      it 'defaults to nil' do
        expect(resource.source).to eq(nil)
      end
    end

    context 'a valid override provided' do
      let(:override) { 'http://path/to/app.bin' }

      it 'returns the override' do
        expect(resource.source).to eq('http://path/to/app.bin')
      end
    end

    context 'an invalid override provided' do
      let(:override) { :monkeys }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#docker_image' do
    let(:override) { nil }
    let(:resource) do
      r = super()
      r.docker_image(override)
      r
    end

    context 'no override provided' do
      context 'a default install' do
        it 'returns nil' do
          expect(resource.docker_image).to eq(nil)
        end
      end

      context 'a container-based install' do
        let(:install_type) { :container }

        it 'returns "shipyard/agent"' do
          expect(resource.docker_image).to eq('shipyard/agent')
        end
      end
    end

    context 'a valid override provided' do
      let(:override) { 'repo/image' }

      context 'a default install' do
        it 'raises an exception' do
          expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end

      context 'a container-based install' do
        let(:install_type) { :container }

        it 'returns the overridden image' do
          expect(resource.docker_image).to eq('repo/image')
        end
      end
    end

    context 'an invalid override provided' do
      let(:override) { :image }

      context 'a default install' do
        it 'raises an exception' do
          expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end

      context 'a container-based install' do
        let(:install_type) { :container }

        it 'raises an exception' do
          expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end
  end

  describe '#version' do
    let(:override) { nil }
    let(:resource) do
      r = super()
      r.version(override)
      r
    end

    context 'no override provided' do
      it 'returns "latest"' do
        expect(resource.version).to eq('latest')
      end
    end

    context 'a valid override provided' do
      let(:override) { '1.2.3' }

      it 'returns the overridden version' do
        expect(resource.version).to eq('1.2.3')
      end
    end

    context 'an invalid override provided' do
      let(:override) { :'1.2.3' }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end
