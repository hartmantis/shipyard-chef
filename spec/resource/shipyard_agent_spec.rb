# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: resource/shipyard_agent
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
require_relative '../../libraries/resource_shipyard_agent'

describe Chef::Resource::ShipyardAgent do
  [:host, :key, :install_type, :version].each do |i|
    let(i) { nil }
  end
  let(:resource) do
    r = Chef::Resource::ShipyardAgent.new('my_agent', nil)
    r.host(host)
    r.key(key)
    r.install_type(install_type)
    r.version(version)
    r
  end

  describe '#initialize' do
    it 'defaults to localhost for the host' do
      expect(resource.instance_variable_get(:@host)).to eq('127.0.0.1')
    end

    it 'defaults to no key' do
      expect(resource.instance_variable_get(:@key)).to eq(nil)
    end

    it 'defaults to the standard install type' do
      expect(resource.instance_variable_get(:@install_type)).to eq(:standard)
      expect(resource.provider).to eq(Chef::Provider::ShipyardAgent::Standard)
    end

    it 'defaults to the latest version' do
      expect(resource.instance_variable_get(:@version)).to eq('latest')
    end

    it 'defaults to install + enable + start actions' do
      expect(resource.instance_variable_get(:@action)).to eq([:install,
                                                              :enable,
                                                              :start])
    end

    it 'defaults the state to uninstalled' do
      expect(resource.installed?).to eq(false)
    end

    it 'defaults the state to disabled' do
      expect(resource.enabled?).to eq(false)
    end

    it 'defaults the state to stopped' do
      expect(resource.running?).to eq(false)
    end
  end

  describe '#host' do
    context 'with no host override provided' do
      it 'defaults to localhost' do
        expect(resource.host).to eq('127.0.0.1')
      end
    end

    context 'with a host override provided' do
      let(:host) { '6.6.6.6' }

      it 'returns that host' do
        expect(resource.host).to eq('6.6.6.6')
      end
    end
  end

  describe '#key' do
    context 'with no key override provided' do
      it 'defaults to no key' do
        expect(resource.key).to eq(nil)
      end
    end

    context 'with a key override provided' do
      let(:key) { 'abcdefg' }

      it 'returns that key' do
        expect(resource.key).to eq('abcdefg')
      end
    end
  end

  describe '#install_type' do
    context 'with no install_type override provided' do
      it 'defaults to a standard install' do
        expect(resource.install_type).to eq(:standard)
      end
    end

    context 'with a valid install_type override provided' do
      let(:install_type) { :container }

      it 'returns that install_type' do
        expect(resource.install_type).to eq(:container)
      end
    end

    context 'with an invalid install_type override provided' do
      let(:install_type) { :github }

      it 'raises an exception' do
        expect { resource.install_type }.to raise_error(
          Chef::Exceptions::ValidationFailed
        )
      end
    end
  end

  describe '#version' do
    context 'with no version override provided' do
      it 'defaults to the latest version' do
        expect(resource.version).to eq('latest')
      end
    end

    context 'with a version override provided' do
      let(:version) { '1.2.3' }

      it 'returns the overridden version' do
        expect(resource.version).to eq(version)
      end
    end
  end
end
