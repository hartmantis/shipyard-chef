# Encoding: UTF-8

require 'spec_helper'

describe 'shipyard::default' do
  let(:runner) { ChefSpec::Runner.new }
  let(:chef_run) { runner.converge(described_recipe) }

  it 'does some stuff' do
    pending
  end
end
