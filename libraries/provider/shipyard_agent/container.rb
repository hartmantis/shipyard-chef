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

class Chef
  class Provider
    class ShipyardAgent < Provider
      # A Chef provider for a container-based Shipyard agent install
      #
      # @author Jonathan Hartman <j@p4nt5.com>
      class Container < ShipyardAgent
        #
        # Install the Shipyard agent via Docker container
        #
        def action_install
        end
      end
    end
  end
end
