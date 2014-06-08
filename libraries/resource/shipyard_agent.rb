# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Resource:: shipyard_agent
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

class Chef
  class Resource
    # A Chef resource for the Shipyard agent application
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgent < Resource
      # Make each status check available as `status?`
      [:installed, :enabled, :running].each do |m|
        attr_accessor m
        alias_method :"#{m}?", m
      end

      def initialize(name, run_context = nil)
        super
        @resource_name = :shipyard_agent

        # Set all the default actions and attributes
        @provider = Chef::Provider::ShipyardAgent::Standard
        @install_type = :standard
        @version = 'latest'
        @action = [:install, :enable, :start]
        @allowed_actions = [
          :install, :uninstall, :enable, :disable, :start, :stop, :restart
        ]

        # State attributes set by the provider
        @installed, @enabled, @running = false, false, false
      end

      #
      # The host for the Shipyard agent to connect to
      #
      # @param [String] arg
      # @return [String]
      #
      def host(arg = nil)
        set_or_return(:host, arg, kind_of: String)
      end

      #
      # The client key to connect to the host with
      #
      # @param [String] arg
      # @return [String]
      #
      def key(arg = nil)
        set_or_return(:key, arg, kind_of: [String, NilClass])
      end

      #
      # The install type for the agent: standard (GitHub) or container
      #
      # @param [Symbol] arg
      # @return [Symbol]
      #
      def install_type(arg = nil)
        # TODO: Generate a class name based on the arg instead of using a case
        arg != @install_type && @provider = case arg
                                            when :standard
                                              Provider::ShipyardAgent::Standard
                                            when :container
                                              Provider::ShipyardAgent::Container
                                            end
        set_or_return(:install_type, arg, kind_of: Symbol)
      end

      #
      # The version of the Shipyard agent to install
      #
      # @param [String] arg
      # @return [String]
      def version(arg = nil)
        set_or_return(:version, arg, kind_of: String)
      end
    end
  end
end
