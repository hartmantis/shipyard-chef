# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent
#
# Copyright 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/provider'
require 'fileutils'

class Chef
  class Provider
    class ShipyardAgent < Provider
      # A Chef provider for a standard (GitHub) Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgent
        #
        # Install the octokit gem for all the actions that use it
        #
        def initialize(new_resource, run_context)
          super
          chef_gem.run_action(:install)
        end

        #
        # Check whether the Shipyard agent is installed
        #
        def installed?
          # TODO: How should upgrades be handled here?
          ::File.exist?(::File.join(deploy_dir, asset_file))
        end

        #
        # Install the Shipyard agent via GitHub artifact repo
        #
        def action_install
          if current_resource.installed?
            Chef::Log.info("Skipping #{current_resource} (already installed)")
          else
            Chef::Log.info("Installing #{current_resource}")
            # TODO: Create a bin/ subdir and put the script there
            directory.run_action(:create)
            Chef::Log.debug("Downloading #{asset} from GitHub")
            remote_file.run_action(:create)
          end
        end

        #
        # Delete the Shipyard agent's deploy dir
        #
        def action_uninstall
          if current_resource.installed?
            Chef::Log.info("Uninstalling #{current_resource}")
            remote_file.run_action(:delete)
            directory.run_action(:delete) if ::Dir.new(deploy_dir).count == 2
          else
            Chef::Log.info("Skipping #{current_resource} (not installed)")
          end
        end

        private

        #
        # The RemoteFile resource for the deployed artifact
        #
        # @return [Chef::Resource::RemoteFile]
        #
        def remote_file
          @remote_file ||= Chef::Resource::RemoteFile.new(
            ::File.join(deploy_dir, asset_file), run_context
          )
          @remote_file.mode('0755')
          @remote_file.source(asset.asset_url({}))
          @remote_file
        end

        #
        # The Directory resource for the deployed artifact
        #
        # @return [Chef::Resource::Directory]
        #
        def directory
          @directory ||= Chef::Resource::Directory.new(deploy_dir, run_context)
          @directory.recursive(true)
          @directory
        end

        #
        # The GitHubCB::Asset object to install Shipyard from
        #
        # @return [GitHubCB::Asset]
        #
        def asset
          # Use GitHubCB::Asset directly; the GitHubAsset resource doesn't
          # provide read access to the asset's URL, which we need for the
          # RemoteFile resource
          #
          # TODO: We're already calling Octokit directly below; is the github
          # cookbook really necessary here anymore?
          @asset ||= GithubCB::Asset.new(repo,
                                         name: asset_file,
                                         release: release)
        end

        #
        # The ChefGem resource for octokit
        #
        # @return [Chef::Resource::ChefGem]
        #
        def chef_gem
          @chef_gem ||= Chef::Resource::ChefGem.new('octokit', run_context)
        end

        #
        # The filename for the GitHub asset
        #
        # @return [String]
        #
        def asset_file
          # TODO: Don't hard code this here
          'shipyard-agent'
        end

        #
        # Translate the 'version' of the resource to a GitHub release string
        #
        # @return [String]
        #
        def release
          case new_resource.version
          when 'latest'
            require 'octokit'
            Octokit.releases(repo).first[:tag_name]
          else
            "v#{new_resource.version}"
          end
        end

        #
        # The GitHub repo for the Shipyard agent
        #
        # @return [String]
        #
        def repo
          'shipyard/shipyard-agent'
        end

        #
        # The directory to which deploys are done
        #
        # @return [String]
        #
        def deploy_dir
          '/usr/bin'
        end
      end
    end
  end
end
