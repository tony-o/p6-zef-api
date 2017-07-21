use Zef::Middleware::Validate;
use Zef::Middleware::JSON::Parse;
use Zef::API::DB;
use JSON::Fast;
use soft;

unit module Zef::Controller::Search;

sub search($req, $res) 
  is validated
  is json-consumer
  is export
{
  my $query = {
    module => ( '-like' => "\%{$req.params<body><module>}%" ),
  };
  qw<author version>.map({
    $query{$_} = ( '-like' => "\%{$req.params<body>{$_}}%" )
     if $req.params<body>{$_}.defined;
  });
  use Data::Dump;
  say Dump $query;
  my $search = db.search('version', $query);
  my @results;
  while $search.next -> $module {
    @results.push(%(
      qw<version version author author commit_id commit module module>.map(-> $db, $key {
        $key => $module.get($db)
      });
    ));
  }
  $res.close(to-json({ status => 0, results => @results }));
};
