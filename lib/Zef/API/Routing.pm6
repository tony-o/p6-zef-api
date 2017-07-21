unit module Zef::API::Routing;

use Zef::API::Util;
use HTTP::Server;
use HTTP::Server::Router;

sub routing(HTTP::Server $server) is export {
  serve $server;

  for routing-yaml<paths>.kv -> $path, $attr {
    try {
      CATCH { default { .say; } };
      my $module = $attr<controller>;
      my $sub    = $attr<sub>;
      require ::($module);
      "hooking $path".say;
      $sub = ::("{$module}::EXPORT::DEFAULT::&{$sub}");
      route $path, $sub;
    };
  }
}
