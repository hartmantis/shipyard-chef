Shipyard Cookbook
=================
[![Cookbook Version](http://img.shields.io/cookbook/v/shipyard.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/shipyard-chef.svg)][travis]

[cookbook]: https://community.opscode.com/cookbooks/clamav
[travis]: http://travis-ci.org/RoboticCheese/clamav-chef

A Chef cookbook for the Shipyard container manager for Docker

Requirements
============

Attributes
==========

Usage
=====

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
