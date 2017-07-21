unit module Zef::API::Middleware;

use HTTP::Server;
use JSON::Fast;
use soft;

sub content-type($req) {
  $req.header('content-type')[0]<content-type>;
}

sub middleware(HTTP::Server $server) is export {
  $server.handler: -> $req, $res {
    $req.params<stash><content-type> = content-type $req;
    $req.params<stash><body-parsed>  = False;
    try {
      $req.params<body> = from-json $req.data.decode.substr(0, *-1);
      $req.params<stash><body-parsed> = True;
    } if $req.params<stash><content-type> eq 'application/json';
    True;
  };
}
