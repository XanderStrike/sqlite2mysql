# sqlite2mysql

### Installation

    gem install sqlite2mysql

Don't include it in your projects, that's not what it's for. This is a command line tool.

### Usage

Run like this:

    sqlite2mysql test.db

This will create a database called testdb in mysql with the exact schema and data as was in `test.db`. You can optionally name it something else in mysql like this:

    sqlite2mysql test.db my_awesome_database

Isn't that handy?

This assumes you can log in as root to your localhost mysql database without a password.

### Contributing

Do.

### License

MIT.
