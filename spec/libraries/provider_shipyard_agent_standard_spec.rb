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
require_relative '../../libraries/provider_shipyard_agent_standard'

describe Chef::Provider::ShipyardAgent::Standard do
  let(:new_resource) do
    double(name: 'my_shipyard_agent',
           install_type: 'standard',
           cookbook_name: 'shipyard')
  end
  let(:provider) { described_class.new(new_resource, nil) }

  describe '#installed?' do
    let(:deploy_dir) { '/opt/shagent' }
    let(:asset_file) { 'yardagent' }
    let(:file_exists) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:deploy_dir)
        .and_return(deploy_dir)
      allow_any_instance_of(described_class).to receive(:asset_file)
        .and_return(asset_file)
      allow(File).to receive(:exist?).with("#{deploy_dir}/#{asset_file}")
        .and_return(file_exists)
    end

    { 'installed' => true, 'not installed' => false }.each do |k, v|
      context "with the agent #{k}" do
        let(:file_exists) { v }

        it "returns #{v}" do
          expect(provider.installed?).to eq(v)
        end
      end
    end
  end

  describe '#installed_version' do
    let(:deploy_dir) { '/opt/shagent' }
    let(:asset_file) { 'yardagent' }
    let(:cmd) { "#{deploy_dir}/#{asset_file} --version" }
    let(:version) { '6.6.6' }
    let(:run_command) { double(stdout: "#{version}\n") }
    let(:shellout) { double(run_command: run_command) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:deploy_dir)
        .and_return(deploy_dir)
      allow_any_instance_of(described_class).to receive(:asset_file)
        .and_return(asset_file)
      allow(Mixlib::ShellOut).to receive(:new).with(cmd).and_return(shellout)
    end

    it 'returns the installed version' do
      expect(provider.installed_version).to eq(version)
    end
  end

  describe '#action_install' do
    it 'does something' do
      pending
    end
  end

  describe '#action_uninstall' do
    it 'does something' do
      pending
    end
  end

  describe '#conf_file' do
    let(:template) { double(cookbook: true, source: true, variables: true) }

    before(:each) do
      allow(Chef::Resource::Template).to receive(:new).and_return(template)
    end

    it 'returns an instance of Chef::Resource::Template' do
      expect(provider.send(:init_script).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#init_script' do
    let(:template) { double(cookbook: true, source: true) }

    before(:each) do
      allow(Chef::Resource::Template).to receive(:new).and_return(template)
    end

    it 'returns an instance of Chef::Resource::Template' do
      expect(provider.send(:init_script).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#remote_file' do
    let(:remote_file) { double(mode: true, source: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:deploy_dir)
        .and_return('test')
      allow_any_instance_of(described_class).to receive(:asset_file)
        .and_return('test')
      allow_any_instance_of(described_class).to receive(:asset_url)
        .and_return('test')
      allow(Chef::Resource::RemoteFile).to receive(:new).and_return(remote_file)
    end

    it 'returns an instance of Chef::Resource::RemoteFile' do
      expect(provider.send(:remote_file).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#directory' do
    let(:directory) { double(recursive: true) }

    before(:each) do
      allow(Chef::Resource::Directory).to receive(:new).and_return(directory)
    end

    it 'returns an instance of Chef::Resource::Directory' do
      expect(provider.send(:directory).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#chef_gem' do
    let(:chef_gem) { double }

    before(:each) do
      allow(Chef::Resource::ChefGem).to receive(:new).and_return(chef_gem)
    end

    it 'returns an instance of Chef::Resource::ChefGem' do
      expect(provider.send(:chef_gem).class).to eq(RSpec::Mocks::Double)
    end
  end

  describe '#asset_url' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:release)
        .and_return('v1.2.3')
    end

    it 'returns a URI for the GitHub asset' do
      expected = URI('https://github.com/shipyard/shipyard-agent/releases/' \
                     'download/v1.2.3/shipyard-agent')
      expect(provider.send(:asset_url)).to eq(expected)
    end
  end

  describe '#release' do
    let(:version) { nil }
    let(:new_resource) do
      double(name: 'my_shipyard_agent',
             install_type: 'standard',
             version: version)
    end

    context 'given a numeric version' do
      let(:version) { '1.2.3' }

      it 'returns the tag name for that version' do
        expect(provider.send(:release)).to eq('v1.2.3')
      end
    end

    context 'tasked with finding the latest version' do
      let(:version) { 'latest' }
      let(:repo) { 'ship' }
      let(:releases) { [{ tag_name: 'v1.2.1' }, { tag_name: 'v1.2.0' }] }

      before(:each) do
        allow_any_instance_of(described_class).to receive(:repo)
          .and_return(repo)
        require 'octokit'
        allow(Octokit).to receive(:releases).with(repo).and_return(releases)
      end

      it 'returns the tag for the most recent version' do
        expect(provider.send(:release)).to eq('v1.2.1')
      end
    end
  end

  describe '#repo' do
    it 'returns the shipyard-agent GitHub repo' do
      expect(provider.send(:repo)).to eq('shipyard/shipyard-agent')
    end
  end

  describe '#deploy_dir' do
    it 'returns the correct deploy dir' do
      expect(provider.send(:deploy_dir)).to eq('/usr/bin')
    end
  end

  describe '#asset_file' do
    it 'returns the application name' do
      expect(provider.send(:asset_file)).to eq('shipyard-agent')
    end
  end
end
