# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Provider:: shipyard_agent_config_standard
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
require 'chef/resource/directory'
require 'chef/resource/template'
require_relative 'resource_shipyard_agent_config'
require_relative 'provider_shipyard_agent_config'

class Chef
  class Provider
    class ShipyardAgentConfig < Provider
      # A Chef provider for a GitHub-based Shipard agent configuration
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Standard < ShipyardAgentConfig
      end
    end
  end
end
