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
require 'chef/provider/deploy'

class Chef
  class Provider
    class ShipyardAgent < Provider
      # A Chef provider for a standard (GitHub) Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgent
        #
        # Install the Shipyard agent via GitHub artifact repo
        #
        def action_install
          return if current_resource.installed?
          asset.run_action(:download)
        end

        #
        # Delete the Shipyard agent's deploy dir
        #
        def action_uninstall
          return unless current_resource.installed?
          directory = Chef::Resource::Directory.new(deploy_dir, run_context)
          directory.recursive(true)
          directory.run_action(:delete)
        end

        private

        #
        # The GitHubAsset object to install Shipyard from
        #
        def asset
          @asset ||= Chef::Resource::GithubAsset.new(asset_file, run_context)
          @asset.repo('shipyard/shipyard-agent')
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
            # TODO: Don't hard code this here
            'v0.3.1'
          else
            "v#{new_resource.version}"
          end
        end

        #
        # The directory to which deploys are done
        #
        # @return [String]
        #
        def deploy_path
          # TODO: Don't hard code this here
          '/opt/shipyard_agent'
        end
      end
    end
  end
end
