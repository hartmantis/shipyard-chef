# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_application_container
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
require_relative 'resource_shipyard_agent_application'
require_relative 'provider_shipyard_agent_application'

class Chef
  class Provider
    class ShipyardAgentApplication < Provider
      # A Chef provider for a container-based Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Container < ShipyardAgentApplication
        def action_create
          image.run_action(:pull)
        end

        def action_delete
          image.run_action(:remove)
        end

        def installed?
          !current_image.tag.nil?
        end

        def version
          return nil unless installed?
          current_image.tag
        end

        private

        def current_image
          @current_image ||= Chef::Provider::DockerImage.new(
            Chef::Resource::DockerImage.new(
              new_resource.docker_image, run_context
            ), run_context
          ).load_current_resource
        end

        def image
          @image ||= Chef::Resource::DockerImage.new(new_resource.docker_image,
                                                     run_context)
          @image.tag(new_resource.version)
          @image
        end
      end
    end
  end
end
