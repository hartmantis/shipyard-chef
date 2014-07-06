# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent
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
require_relative '../../libraries/provider_shipyard_agent'

describe Chef::Provider::ShipyardAgent do
  let(:new_resource) do
    double(name: 'my_shipyard_agent', install_type: 'test')
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#whyrun_supported?' do
    it 'supports WhyRun mode' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    let(:resource) do
      double(install_type: true,
             host: true,
             key: true,
             version: true,
             :'installed=' => true,
             :'enabled=' => true,
             :'running=' => true)

    end

    before(:each) do
      allow(Chef::Resource::ShipyardAgent).to receive(:new).and_return(resource)
      [
        :installed_host,
        :installed_key,
        :installed_version,
        :installed?,
        :enabled?,
        :running?
      ].each do |m|
        allow_any_instance_of(described_class).to receive(m).and_return(true)
      end
    end

    it 'returns an instance of Chef::Resource::ShipyardAgent' do
      expected = RSpec::Mocks::Double
      expect(provider.load_current_resource.class).to eq(expected)
    end
  end

  describe '#action_restart' do
    it 'stops and starts the service' do
      [:action_stop, :action_start].each do |a|
        expect_any_instance_of(described_class).to receive(a).and_return(true)
      end
      provider.action_restart
    end
  end

  %w(
    action_install
    action_uninstall
    action_enable
    action_disable
    action_start
    action_stop
    installed?
    enabled?
    running?
    package
    service
  ).each do |method|
    describe "##{method}" do
      it 'raises a NotImplemented exception' do
        expected = Chef::Provider::ShipyardAgent::NotImplemented
        expect { provider.send(method) }.to raise_error(expected)
      end
    end
  end
end
