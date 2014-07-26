# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/provider_shipyard_agent_application_standard
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
require_relative '../../libraries/provider_shipyard_agent_application_standard'

describe Chef::Provider::ShipyardAgentApplication::Standard do
  let(:new_resource_version) { 'latest' }
  let(:new_resource) do
    double(name: 'my_agent',
           install_type: 'test',
           :'created=' => true,
           version: new_resource_version)
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#action_create' do
    let(:octokit) { double(run_action: true) }
    let(:app_dir) { double(run_action: true, recursive: true) }
    let(:app_file) { double(run_action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:octokit)
        .and_return(octokit)
      allow_any_instance_of(described_class).to receive(:app_dir)
        .and_return(app_dir)
      allow_any_instance_of(described_class).to receive(:app_file)
        .and_return(app_file)
    end

    it 'installs Octokit' do
      expect(octokit).to receive(:run_action).with(:install)
      provider.action_create
    end

    it 'creates the dir for the application file recursively' do
      expect(app_dir).to receive(:recursive).with(true)
      expect(app_dir).to receive(:run_action).with(:create)
      provider.action_create
    end

    it 'creates the application file' do
      expect(app_file).to receive(:run_action).with(:create)
      provider.action_create
    end
  end

  describe '#action_delete' do
    let(:octokit) { double(run_action: true) }
    let(:app_dir) { double(run_action: true, only_if: true) }
    let(:app_file) { double(run_action: true) }
    let(:deploy_dir) { '/opt/ship' }

    before(:each) do
      {
        octokit: octokit,
        app_dir: app_dir,
        app_file: app_file,
        deploy_dir: deploy_dir
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    it 'removes the application file' do
      expect(app_file).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'removes the application dir if empty' do
      expect(app_dir).to receive(:run_action).with(:delete)
      provider.action_delete
    end

    it 'leaves Octokit in place' do
      expect(octokit).to_not receive(:run_action)
      provider.action_delete
    end
  end

  describe '#installed?' do
    let(:installed) { nil }
    let(:deploy_dir) { '/opt/ship' }
    let(:app_name) { 'yard' }
    
    before(:each) do
      allow_any_instance_of(described_class).to receive(:deploy_dir)
        .and_return(deploy_dir)
      allow_any_instance_of(described_class).to receive(:app_name)
        .and_return(app_name)
      allow(::File).to receive(:exist?).with("#{deploy_dir}/#{app_name}")
        .and_return(installed)
    end

    context 'an existing app binary' do
      let(:installed) { true }

      it 'returns true' do
        expect(provider.installed?).to eq(true)
      end
    end

    context 'a non-existent app binary' do
      let(:installed) { false }

      it 'returns false' do
        expect(provider.installed?).to eq(false)
      end
    end
  end

  describe '#version' do
    let(:installed) { nil }
    let(:shellout_res) { nil }
    let(:shellout) { double(run_command: double(stdout: shellout_res)) }
    let(:deploy_dir) { '/opt/ship' }
    let(:app_name) { 'yard' }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:installed?)
        .and_return(installed)
      allow_any_instance_of(described_class).to receive(:deploy_dir)
        .and_return(deploy_dir)
      allow_any_instance_of(described_class).to receive(:app_name)
        .and_return(app_name)
      allow(Mixlib::ShellOut).to receive(:new)
        .with("#{deploy_dir}/#{app_name} --version").and_return(shellout)
    end

    context 'the agent not installed' do
      let(:installed) { false }

      it 'returns nil' do
        expect(provider.version).to eq(nil)
      end
    end

    context 'the agent installed' do
      let(:installed) { true }
      let(:shellout_res) { "1.2.3\n" }

      it 'returns the version number' do
        expect(provider.version).to eq('1.2.3')
      end
    end
  end
end
