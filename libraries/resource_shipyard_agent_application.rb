# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Resource:: shipyard_agent_application
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

require 'chef/resource'
require 'chef/mixin/params_validate'
require_relative 'provider_shipyard_agent_application'
require_relative 'provider_shipyard_agent_application_standard'

class Chef
  class Resource
    # A Chef resource for the Shipyard agent application
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgentApplication < Resource
      DEFAULT_IMAGE = 'shipyard/agent'

      attr_accessor :created

      def initialize(name, run_context = nil)
        super
        @resource_name = :shipyard_agent_application
        @provider = Provider::ShipyardAgent::Application::Standard
        @action = :create
        @allowed_actions = [:create, :delete, :install, :uninstall]

        # State attributes set by the provider
        @created = false
      end

      #
      # The install type for the agent--standard (GitHub) or container
      #
      # @param [Symbol, String, NilClass] arg
      # @return [Symbol]
      #
      def install_type(arg = nil)
        arg = arg.to_sym if arg
        set_or_return(:install_type,
                      arg,
                      kind_of: Symbol,
                      equal_to: [:standard, :container],
                      default: :standard)
      end

      #
      # The source to pull in the Shipyard application from
      #
      # @param [String, NilClass] arg
      # @return [String, NilClass]
      #
      def source(arg = nil)
        set_or_return(:source, arg, kind_of: [String, NilClass], default: nil)
      end

      #
      # The Docker image to download for a container-based install
      #
      # @param [String, NilClass]
      # @return [String, NilClass]
      #
      def docker_image(arg = nil)
        set_or_return(:docker_image,
                      arg,
                      kind_of: [String, NilClass],
                      default: install_type == :container ? DEFAULT_IMAGE : nil,
                      callbacks: {
                        'A `docker_image` requires a container-based install' =>
                          ->(_) { install_type != :container },
                        'A `docker_image` cannot be used with a `source`' =>
                          ->(_) { !source.nil? }
                      })
      end

      #
      # The version of the agent to install
      #
      # @param [String, NilClass]
      # @return [String, NilClass]
      #
      def version(arg = nil)
        set_or_return(:version, arg, kind_of: String, default: 'latest')
      end
    end
  end
end
