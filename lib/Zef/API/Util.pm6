unit module Zef::API::Config;

use YAML::Parser::LibYAML;

my %cache;

%cache<routing> = yaml-parse 'routing.yaml';

sub routing-yaml is export {
  %cache<routing>;
}
