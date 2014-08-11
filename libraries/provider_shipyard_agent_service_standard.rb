# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_service_standard
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
require 'chef/resource/service'
require 'chef/resource/template'
require_relative 'resource_shipyard_agent_service'
require_relative 'provider_shipyard_agent_service'
require_relative 'shipyard_helpers'

class Chef
  class Provider
    class ShipyardAgentService < Provider
      # A Chef provider for a GitHub-based Shipard agent service
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgentService
        include Shipyard::Helpers::Agent

        #
        # Drop off the init script for the service
        #
        def action_create
          init_script.run_action(:create)
        end

        #
        # Delete the init script (after stopping and disabling the service)
        #
        def action_delete
          action_stop
          action_disable
          init_script.run_action(:delete)
        end

        #
        # Pass the enable/disable/start/stop actions on to the inner service
        # resource
        #
        [:enable, :disable, :start, :stop].each do |act|
          define_method(:"action_#{act}", proc { service.run_action(act) })
        end

        #
        # Check whether the init script exists on the filesystem
        #
        # @return [TrueClass, FalseClass]
        #
        def created?
          ::File.exist?(init_script.name)
        end

        private


        #
        # The inner service resource for this service
        #
        # @return [Chef::Resource::Service]
        #
        def service
          @service ||= Chef::Resource::Service.new(app_name, run_context)
          @service.provider(
            Chef::Provider::Service.const_get(init_system.to_s.capitalize)
          )
          @service
        end

        #
        # The template resource for the init script
        #
        # @return [Chef::Resource::Template]
        #
        def init_script
          @init_script ||= Chef::Resource::Template.new(
            ::File.join(init_dir, "#{app_name}.conf"), run_context
          )
          @init_script.cookbook(cookbook_name.to_s)
          @init_script.source(::File.join(init_system.to_s,
                                          "#{app_name}.conf.erb"))
          @init_script.variables(config_file: new_resource.config_file)
          @init_script
        end

        #
        # Determine the init directory based on the node's init system
        #
        # @return [String]
        #
        def init_dir
          case init_system
          when :upstart
            '/etc/init'
          end
        end

        #
        # Return the init system for this node
        #
        # @return [Symbol]
        #
        def init_system
          :upstart
        end
      end
    end
  end
end
