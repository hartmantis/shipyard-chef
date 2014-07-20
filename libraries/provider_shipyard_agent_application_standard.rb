# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_application_standard
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
require 'chef/resource/chef_gem'
require 'chef/resource/directory'
require 'chef/resource/remote_file'
require 'mixlib/shellout'
require_relative 'resource_shipyard_agent_application'
require_relative 'provider_shipyard_agent_application'

class Chef
  class Provider
    class ShipyardAgentApplication < Provider
      # A Chef provider for a GitHub-based Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgentApplication
        def action_create
          octokit.run_action(:install)
          app_dir.run_action(:create)
          app_file.run_action(:create)
        end

        def action_delete
          app_file.run_action(:delete)
          app_dir.run_action(:delete) if ::Dir.new(deploy_dir).count == 2
        end

        def installed?
          ::File.exist?(::File.join(deploy_dir, app_name))
        end

        def version
          shout = Mixlib::ShellOut.new("#{deploy_dir}/#{app_name} --version")
          shout.run_command.stdout.strip
        end

        private

        #
        # A RemoteFile resource for the application binary
        #
        # @return [Chef::Resource::RemoteFile]
        #
        def app_file
          @app_file ||= Chef::Resource::RemoteFile.new(
            ::File.join(deploy_dir, app_name), run_context
          )
          @app_file.mode('0755')
          @app_file.source(asset_url.to_s)
          @app_file
        end

        #
        # A Directory resource for the application install path
        #
        # @return [Chef::Resource::Directory]
        #
        def app_dir
          @app_dir ||= Chef::Resource::Directory.new(deploy_dir, run_context)
          @app_dir.recursive(true)
          @app_dir
        end

        #
        # Construct a URL to pull the binary file down from
        #
        # @return [URI]
        #
        def asset_url
          URI("https://github.com/#{repo}/releases/download/#{release}/" <<
              app_name)
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
        # The ChefGem resource for octokit
        #
        # @return [Chef::Resource::ChefGem]
        #
        def octokit
          @octokit ||= Chef::Resource::ChefGem.new('octokit', run_context)
        end

        #
        # The GitHub repo for the agent
        #
        # @return [String]
        #
        def repo
          "shipyard/#{app_name}"
        end

        #
        # The dir in which to deploy the agent binary
        #
        # @return [String]
        #
        def deploy_dir
          '/usr/bin'
        end

        #
        # The name of the agent application in GitHub repos, filenames, etc.
        #
        # @return [String]
        #
        def app_name
          'shipyard-agent'
        end
      end
    end
  end
end
