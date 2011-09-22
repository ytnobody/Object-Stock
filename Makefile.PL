use inc::Module::Install;
name 'Object-Stock';
all_from 'lib/Object/Stock.pm';

requires 'Time::HiRes';
requires 'Number::Tolerant';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
