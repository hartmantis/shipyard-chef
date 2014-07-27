# Encoding: UTF-8
#
# Cookbook Name:: shipyard
# Spec:: libraries/shipyard_agent_helpers
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
#

require_relative '../spec_helper'
require_relative '../../libraries/shipyard_agent_helpers'

describe Shipyard::Agent::Helpers do
  let(:test_obj) { Class.new { include Shipyard::Agent::Helpers }.new }

  describe '#app_name' do
    it 'returns "shipyard-agent"' do
      expect(test_obj.app_name).to eq('shipyard-agent')
    end
  end
end
