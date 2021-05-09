## Setup

```sh
git config receive.denyCurrentBranch updateInstead
bundle config --local deployment true
bundle install
npm install
./update.rb
middleman build
```
