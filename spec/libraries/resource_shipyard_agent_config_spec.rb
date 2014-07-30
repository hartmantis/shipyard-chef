# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/resource_shipyard_agent_config
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
require_relative '../../libraries/resource_shipyard_agent_config'

describe Chef::Resource::ShipyardAgentConfig do
  [:install_type, :source].each do |i|
    let(i) { nil }
  end
  let(:resource) do
    r = Chef::Resource::ShipyardAgentConfig.new('my_agent', nil)
    r.install_type(install_type)
    r.source(source)
    r
  end

  describe '#initialize' do
    it 'defaults to the GitHub provider' do
      expected = Chef::Provider::ShipyardAgentConfig::Standard
      expect(resource.instance_variable_get(:@provider)).to eq(expected)
    end

    it 'defaults to the "create" action' do
      expect(resource.instance_variable_get(:@action)).to eq(:create)
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
      it 'defaults to a GitHub install' do
        expect(resource.install_type).to eq(:standard)
      end
    end

    context 'a valid override provided' do
      let(:override) { 'container' }

      it 'returns the override symbolized' do
        expect(resource.install_type).to eq(:container)
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
      it 'defaults to "shipyard-agent.default.erb"' do
        expect(resource.source).to eq('shipyard-agent.default.erb')
      end
    end

    context 'a valid override provided' do
      let(:override) { 'somewhere/else.erb' }

      it 'returns the override' do
        expect(resource.source).to eq('somewhere/else.erb')
      end
    end

    context 'an invalid override provided' do
      let(:override) { :monkeys }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end

  describe '#path' do
    let(:override) { nil }
    let(:resource) do
      r = super()
      r.path(override)
      r
    end

    context 'no override provided' do
      it 'defaults to "/etc/shipyard-agent"' do
        expect(resource.path).to eq('/etc/shipyard-agent')
      end
    end

    context 'a valid override provided' do
      let(:override) { '/opt/shipyard' }

      it 'returns the override' do
        expect(resource.path).to eq('/opt/shipyard')
      end
    end

    context 'an invalid override provided' do
      let(:override) { :badbadbad }

      it 'raises an exception' do
        expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
      end
    end
  end
end