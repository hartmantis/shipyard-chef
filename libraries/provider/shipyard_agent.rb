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
require_relative '../resource/shipyard_agent'

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
        if installed?
          @current_resource.installed = installed?
          @current_resource.version(installed_version?)
        end
        @current_resource
      end

      #
      # Do the current version and desired version match?
      #
      # @return [TrueClass, FalseClass]
      #
      def needs_updowngrade?
        current_resource.version != new_resource.version
      end

      #
      # Restart the Shipyard agent
      #
      def action_restart
        stop && start
      end

      # Actions and status checks vary by installation method, need to be
      # defined by the specific providers
      [:install, :uninstall, :enable, :disable, :start, :stop].each do |act|
        define_method(:"action_#{act}", proc { fail(NotImplemented, act) })
      end

      [:installed?, :enabled?, :running?].each do |status|
        define_method(status, proc { fail(NotImplemented, status) })
      end
    end

    # A custom exception class for not implemented methods
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class NotImplemented < StandardError
      def initialize(method)
        super("Method `#{method}` has not been implemented")
      end
    end
  end
end
