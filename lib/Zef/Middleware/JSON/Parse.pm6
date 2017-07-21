use JSON::Fast;
use Zef::API::Util;
no precompilation;
unit module Zef::Middleware::JSON::Parse;

multi sub trait_mod:<is>(Routine $sub, :$json-consumer!) is export { 
  $sub.wrap(-> $req, $res {
    unless $req.params<stash><body-parsed> {
      $res.close(to-json({
        status => 500,
        error  => 'invalid json',
        info   => 'The body sent contained invalid JSON or the content-type was wrong',
      }));
      return False;
    }
    callsame;
  });
}
