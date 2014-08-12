# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Resource:: docker_container
#
# Copyright (C) 2014, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'spec_helper'

class Chef
  class Resource
    # A fake docker_container resource
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class DockerContainer < Resource
      def initialize(name, run_context = nil)
        super
        @resource_name = :docker_container
        @action = :run
        @allowed_actions = [:run, :kill]
      end

      def detach(arg = nil)
        set_or_return(:detach, arg, kind_of: [TrueClass, FalseClass])
      end

      def port(arg = nil)
        set_or_return(:port, arg, kind_of: String)
      end

      def env_file(arg = nil)
        set_or_return(:env_file, arg, kind_of: String)
      end

      def image(arg = nil)
        set_or_return(:image, arg, kind_of: String)
      end
    end
  end
end
