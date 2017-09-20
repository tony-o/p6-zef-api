unit module Zef::API::DB;

use DB::ORM::Quicky;

my DB::ORM::Quicky $orm .=new(:debug, config => {
  default-col-id => 'id',
  quote          => '',
});

$orm.connect(
  driver  => 'Pg',
  options => %(
    database => 'tonyo',
  ),
) or die 'Unable to connect to requested server';

sub db is export {
  $orm;
};
