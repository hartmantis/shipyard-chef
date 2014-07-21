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
require_relative 'resource_shipyard_agent'
require_relative 'shipyard_agent_service_standard'

class Chef
  class Provider
    # A Chef provider for the Shipard agent application
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgent < Provider
      #
      # Pull in the correct install type-dependent methods
      #
      def initialize(new_resource, run_context)
        case new_resource.install_type
        when :standard
          include Shipyard::Agent::Service::Standard
          include Shipyard::Agent::State::Standard
          include Shipyard::Agent::Actions::Standard
        else
          fail NotImplemented, new_resource.install_type
        end
        super
      end

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
      # @return [Chef::Resource::ShipyardAgent]
      #
      def load_current_resource
        @current_resource ||= Resource::ShipyardAgent.new(new_resource.name)
        @current_resource.install_type(new_resource.install_type)
        @current_resource.host(installed_host)
        @current_resource.key(installed_key)
        @current_resource.version(installed_version)
        @current_resource.installed = installed?
        @current_resource.enabled = enabled?
        @current_resource.running = running?
        @current_resource
      end

      [:enable, :disable, :start, :stop, :restart].each do |action|
        define_method(:"action_#{action}", proc { service.run_action(action) })
      end

      # Each implementation of the provider needs to define certain actions...
      [:install, :uninstall].each do |act|
        define_method(:"action_#{act}", proc { fail(NotImplemented, act) })
      end

      # ...and certain statuses...
      [:installed?, :enabled?, :running?].each do |status|
        define_method(status, proc { fail(NotImplemented, status) })
      end

      # ...and certain sub-resources
      [:package, :service].each do |resource|
        define_method(resource, proc { fail(NotImplemented, resource) })
      end
    end

    # A custom exception class for not implemented methods
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class NotImplemented < StandardError
      def initialize(item)
        super("`#{item}` has not been implemented")
      end
    end
  end
end