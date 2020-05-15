[![Build status](https://ci.appveyor.com/api/projects/status/otamhaq5pj75ektk/branch/master?svg=true)](https://ci.appveyor.com/project/cfillion/reapack-com/branch/master)

## Setup

```sh
git config receive.denyCurrentBranch updateInstead
bundle config --local deployment true
bundle install
npm install
./update.rb
middleman build
```
