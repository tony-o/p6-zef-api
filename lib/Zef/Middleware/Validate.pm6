use Zef::API::Util;
use experimental :cached;

no precompilation;

unit module Zef::Middleware::Validate;

my $routing = routing-yaml<paths>;

sub route-params($path) is cached {
  my $ppath = $routing{$path}; 
  $ppath<parameters>.defined ?? $ppath<parameters> !! Nil;
}


multi sub trait_mod:<is>(Routine $sub, :$validated!) is export { 
  $sub.wrap: -> $req, $res {
    $req.params.perl.say;
    my @params = |route-params($req.params<stash><route>);
    $req.params<stash><validated> = True;
    @params.perl.say;
    for @params -> $param {
      my $x;
      if $param<in>.lc eq 'body' {
        $x = $req.params<body>{$param<name>};
      } else {
        $x = $req.params{$param<name>};
      }
      if !$x.defined && !$param<optional> {  
        $res.close(to-json {
          status => 501,
          error  => "missing required key in JSON body: {$param<name>}",
          info   => "Please provide parameter '{$param<name>}' in this request.\n\t{@params.map({ $_<name> ~ ':' ~ ( $_<description> // 'no description provided' ) }).join("\n\t")}",
        });
        $req.params<stash><validated> = False;
        last;
      }
    }
    callsame if $req.params<stash><validated>;
  };
}
