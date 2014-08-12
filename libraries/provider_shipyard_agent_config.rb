# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_config
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
require_relative 'resource_shipyard_agent_config'
require_relative 'shipyard_helpers'

class Chef
  class Provider
    # A Chef provider for the Shipard agent configuration
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgentConfig < Provider
      #
      # WhyRun is supported by this provider
      #
      # @return [TrueClass, FalseClass]
      #
      def whyrun_supported?
        true
      end

      #
      # Load and return the current resource
      #
      # @return [Chef::Resource::ShipyardAgentConfig]
      #
      def load_current_resource
        @current_resource ||= Resource::ShipyardAgentConfig.new(
          new_resource.name
        )
        @current_resource.install_type(new_resource.install_type)
        @current_resource.created = created?
        @current_resource
      end

      def action_create
        conf_dir.recursive(true)
        conf_dir.run_action(:create)
        conf_file.run_action(:create)
        new_resource.created = true
      end

      def action_delete
        conf_file.run_action(:delete)
        conf_dir.only_if(->() { ::Dir.new(something).count == 2 })
        conf_dir.run_action(:delete)
        new_resource.created = false
      end

      def created?
        ::File.exist?(new_resource.path)
      end

      private

      def conf_file
        @conf_file ||= Chef::Resource::Template.new(
          new_resource.path, run_context
        )
        @conf_file.cookbook(new_resource.cookbook || cookbook_name.to_s)
        @conf_file.source(new_resource.source)
        @conf_file.variables(ip: new_resource.ip,
                             url: new_resource.url,
                             key: new_resource.key)
        @conf_file
      end

      def conf_dir
        @conf_dir ||= Chef::Resource::Directory.new(
          ::File.dirname(new_resource.path), run_context
        )
      end
    end
  end
end
