use Zef::API::DB;
use HTTP::Server::Middleware::JSON;
use Zef::Middleware::Validate;
use JSON::Fast;

unit module Zef::Controller::User;
sub register($req, $res)
  is json-consumer
  is validated
  is export 
{
  my %response = status => 0, ;
  my %query =
    '-or' => [
      username => $req.params<body><username>,
      email    => $req.params<body><email>,
    ],
  ; 
   
  my $search = db.search('users', %query);
  my $count  = try { $search.first ?? 1 !! 0 } // 0;
  if $count {
    %response<status> = 100;
    %response<error>  = 'user_exists';
  } else {
    %response<status> = 150;
    %response<error>  = 'unknown_error';
    try {
      CATCH { default { .say; } }
      my $user = db.create('users');
      $user.set({ username => $req.params<body><username> });
      $user.set({ password => $req.params<body><password> });
      $user.set({ email    => $req.params<body><email> });
      $user.save;
      %response<status> = 0;
      %response<data>   = {
        user-id => $user.id;
      };
      %response.DELETE-KEY('error');
    };
  }

  $res.close(to-json(%response));
}
