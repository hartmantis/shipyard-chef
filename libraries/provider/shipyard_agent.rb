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
require_relative 'shipyard_agent/container'
require_relative 'shipyard_agent/standard'

class Chef
  class Provider
    # A Chef provider for the Shipard agent application
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgent < Provider
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
        @current_resource.version(new_resource.version)
        @current_resource
      end

      #
      # Restart the Shipyard agent
      #
      def action_restart
        stop && start
      end

      [:install, :uninstall, :enable, :disable, :start, :stop].each do |act|
        define_method(:"action_#{act}", proc { fail(NotImplemented, act) })
      end
    end

    # A custom exception class for not implemented methods
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class NotImplemented < StandardError
      def initialize(action)
        super("Action `#{action}` has not been implemented")
      end
    end
  end
end
