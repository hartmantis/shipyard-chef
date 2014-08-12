# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_service_container
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
require_relative 'shipyard_helpers'
require_relative 'resource_shipyard_agent_service'
require_relative 'provider_shipyard_agent_service'

class Chef
  class Provider
    class ShipyardAgentService < Provider
      # A Chef provider for a container-based Shipard agent service
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Container < ShipyardAgentService
        include Shipyard::Helpers::Agent

        #
        # Do nothing since the container has no init script
        #
        def action_create
          Chef::Log.debug('Nothing to do in `create` action for a ' \
                          'container-based service resource')
        end

        #
        # Do nothing since the container has no init script
        #
        def action_delete
          Chef::Log.debug('Nothing to do in `delete` action for a ' \
                          'container-based service resource')
        end

        #
        # TODO - Wrap the container in an init system?
        #
        def action_enable
          # TODO
        end

        #
        # TODO - Wrap the container in an init system?
        #
        def action_disable
          # TODO
        end

        #
        # Start up the agent's Docker container
        #
        def action_start
          container.run_action(:run)
        end

        #
        # Kill the agent's Docker container
        #
        def action_stop
          container.run_action(:kill)
        end

        #
        # Check whether the resource has been created or not (always true)
        #
        # @return [TrueClass, FalseClass]
        #
        def created?
          true
        end

        private

        #
        # The inner Docker container resource
        #
        # @return [Chef::Resource::DockerContainer
        #
        def container
          @container ||= Chef::Resource::DockerContainer.new(app_name,
                                                             run_context)
          @container.image(new_resource.docker_image)
          @container.detach(true)
          @container.port('4500:4500')
          @container.env_file(new_resource.config_file)
          @container
        end
      end
    end
  end
end
