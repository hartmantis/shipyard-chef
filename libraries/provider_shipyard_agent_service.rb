# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_service
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
require_relative 'resource_shipyard_agent_service'
require_relative 'shipyard_helpers'

class Chef
  class Provider
    # A Chef provider for the Shipard agent service
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgentService < Provider
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
      # @return [Chef::Resource::ShipyardAgentService]
      #
      def load_current_resource
        @current_resource ||= Resource::ShipyardAgentService.new(
          new_resource.name
        )
        @current_resource.install_type(new_resource.install_type)
        @current_resource.created = created?
        @current_resource
      end

      [
        :action_create,
        :action_delete,
        :action_enable,
        :action_disable,
        :action_start,
        :action_stop,
        :action_restart,
        :created?
      ].each do |m|
        define_method(
          m, proc { fail(Shipyard::Exceptions::MethodNotImplemented, m) }
        )
      end
    end
  end
end
