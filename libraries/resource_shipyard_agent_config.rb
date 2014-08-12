# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Resource:: shipyard_agent_config
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
require 'ipaddr'
require_relative 'shipyard_helpers'
require_relative 'provider_shipyard_agent_config'
require_relative 'provider_shipyard_agent_config_container'
require_relative 'provider_shipyard_agent_config_standard'

class Chef
  class Resource
    # A Chef resource for the Shipyard agent configuration
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class ShipyardAgentConfig < Resource
      include Shipyard::Helpers::Agent

      attr_accessor :created

      provider_base Chef::Provider::ShipyardAgentConfig

      def initialize(name, run_context = nil)
        super
        @resource_name = :shipyard_agent_config
        @provider = Provider::ShipyardAgentConfig::Standard
        @action = :create
        @allowed_actions = [:create, :delete]

        # State attributes set by the provider
        @created = false
      end

      #
      # The install type of the agent--standard (GitHub) or container
      #
      # @param [Symbol, String, NilClass] arg
      # @return [Symbol]
      #
      def install_type(arg = nil)
        res = set_or_return(:install_type,
                            arg.nil? ? arg : arg.to_sym,
                            kind_of: Symbol,
                            equal_to: [:standard, :container],
                            default: :standard)
        provider(arg.to_s.capitalize) if arg
        res
      end

      #
      # The cookbook to pull the config template from
      #
      # @param [String, NilClass] arg
      # @return [String, NilClass]
      #
      def cookbook(arg = nil)
        set_or_return(:cookbook,
                      arg,
                      kind_of: [String, NilClass],
                      default: nil)
      end

      #
      # The source for the config file template
      #
      # @param [String, NilClass] arg
      # @return [String]
      #
      def source(arg = nil)
        set_or_return(:source,
                      arg,
                      kind_of: String,
                      default: "#{app_name}.default.erb")
      end

      #
      # The intended path to the config file
      #
      # @param [String, NilClass] arg
      # @return [String]
      #
      def path(arg = nil)
        set_or_return(:path,
                      arg,
                      kind_of: String,
                      default: ::File.join('/etc/default', app_name))
      end

      #
      # The IP address to bind to
      #
      # @param [String, NilClass] arg
      # @return [String]
      #
      def ip(arg = nil)
        set_or_return(:ip,
                      arg,
                      kind_of: String,
                      default: '127.0.0.1',
                      callbacks: {
                        'An `ip` must be a valid IP address' =>
                          ->(a) { a.nil? ? true : !IPAddr.new(a).nil? }
                      })
      end

      #
      # The URL to the Shipyard host
      #
      # @param [String, NilClass] arg
      # @return [String]
      #
      def url(arg = nil)
        set_or_return(:url,
                      arg,
                      kind_of: String,
                      default: 'http://localhost:8000')
      end

      #
      # The key for access to the Shipyard host
      #
      # @param [String, NilClass] arg
      # @return [String, NilClass]
      #
      def key(arg = nil)
        set_or_return(:key,
                      arg,
                      kind_of: [String, NilClass],
                      default: nil)
      end
    end
  end
end
