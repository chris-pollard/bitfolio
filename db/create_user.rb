require 'bcrypt'
require 'pg'

require_relative 'lib'

username = 'crspy'
password = 'platypus'

password_digest = BCrypt::Password.create(password)

run_sql('INSERT INTO users (username, password_digest) VALUES ($1, $2);',[username, password_digest])