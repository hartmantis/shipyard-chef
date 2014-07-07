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
    double(name: 'my_shipyard_agent', install_type: 'standard')
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
end
