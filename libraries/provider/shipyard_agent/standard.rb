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
require 'octokit'

class Chef
  class Provider
    class ShipyardAgent < Provider
      # A Chef provider for a standard (GitHub) Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgent
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
            asset.run_action(:download)
            download_and_deploy
          end
        end

        #
        # Delete the Shipyard agent's deploy dir
        #
        def action_uninstall
          if current_resource.installed?
            Chef::Log.info("Uninstalling #{current_resource}")
            directory.run_action(:delete)
          else
            Chef::Log.info("Skipping #{current_resource} (not installed)")
          end
        end

        private

        #
        # Download the GitHubAsset and deploy it to the deploy_dir
        #
        def download_and_deploy
          Chef::Log.debug("Downloading #{asset} from GitHub")
          asset.run_action(:download)
          Chef::Log.debug("Moving #{asset_file} into place")
          FileUtils.mv(asset.asset_path,
                       ::File.join(deploy_dir, asset_file),
                       force: true)
          FileUtils.chmod(0755, ::File.join(deploy_dir, asset_file))
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
        # The GitHubAsset object to install Shipyard from
        #
        # @return [Chef::Resource::GitHubAsset]
        #
        def asset
          @asset ||= Chef::Resource::GithubAsset.new(asset_file, run_context)
          @asset.repo(repo)
          @asset.release(revision)
          @asset
        end

        #
        # The filename for the GitHub asset tarball
        #
        # @return [String]
        #
        def asset_file
          # TODO: Don't hard code this here
          'shipyard-agent'
        end

        #
        # Translate the 'version' of the resource to a GitHub tag
        #
        # @return [String]
        #
        def revision
          case new_resource.version
          when 'latest'
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
          # TODO: Don't hard code this here
          '/opt/shipyard_agent'
        end
      end
    end
  end
end
