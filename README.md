Shipyard Cookbook
=================
[![Cookbook Version](http://img.shields.io/cookbook/v/shipyard.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/shipyard-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/shipyard
[travis]: http://travis-ci.org/RoboticCheese/shipyard-chef

A Chef cookbook for the Shipyard container manager for Docker

Requirements
============
The binaries distributed for Shipyard are compiled for Ubuntu, so a 'standard'
install is not possible on RHEL family systems.

Usage
=====
This cookbook contains a set of resources that can be consumed directly by
your own recipes, and also contains some basic recipes of its own, if that
suits your needs better.

Resources
=========

***shipyard_agent***

Installs and configures an instance of Shipyard's agent application to connect
to the primary Shipyard host. A number of options are available:

* `install_type` - The agent can be installed as a Docker `:container` or as a
  more `:standard` (the default) binary application
* `version` - The version of the agent to install or the string `'latest'` (the
  default)
* `host` - The Shipyard host the agent will connect to (default:
  `'http://localhost:8000'`)
* `key` - The client key the agent will use when connecting to the host
  (defaults to `nil` and attempting to register with the host, generating a
  request that needs to be approved in the Shipyard UI
* `action` - Any of `:install`, `:uninstall`, `:enable`, `:disable`, `:start`,
  `:stop`, `:restart` (defaults to `[:install, :enable, :start]`)

For example, to install the latest version as a container in Docker:

    shipyard_agent 'agent' do
      install_type :container
      # version 'latest' # The default behavior
      host 'http://1.2.3.4:8000'
      key '1234567890qwertyuiop'
      action [:install, :enable, :start] # The default behavior
    end

Recipes
=======

***agent***

Implements the `shipyard_agent` resource to do an optional install driven by a
set of node attributes under the `node['shipyard']['agent']` namespace

Testing
=======
This cookbook implements several suites of syntax, style, unit, integration and
acceptance tests, utilizing a number of tools:

* [Rubocop](https://github.com/bbatsov/rubocop) for Ruby lint tests
* [FoodCritic](http://www.foodcritic.io) for Chef lint tests
* [ChefSpec](https://github.com/sethvargo/chefspec) for the cookbook unit tests
* [Serverspec](http://serverspec.org) for post-converge integration tests
* [Cucumber](http://cukes.info/) for high-level acceptance tests
* [Test Kitchen](http://kitchen.ci) to tie all the tests together

To run the entire suite of tests, simple:

    rake

To Do
=====
* TODO: The shipyard-agent binary distributed via GitHub doesn't run under
CentOS. Support can be added if it's switched to use an Omnibus project.
* TODO: Is there any way to allow someone to "upgrade" from a container to a
GitHub deploy or vice versa?

Contributing
============
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run style checks and RSpec tests (`bundle exec rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

License & Authors
-----------------
- Author:: Jonathan Hartman (<j@p4nt5.com>)

```text
Copyright 2014, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
