class User < ApplicationRecord

  #ativa a criptografia da senha
  has_secure_password

  validates :name, presence: true, length: { maximum: 20 }
  before_save { self.email = email.downcase }
  validates :email, presence: true, format: {with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :create}, uniqueness: {case_sensitive: false}
  validates :password_digest, presence: true, length: { minimum: 3 }
  #validates :ccli,:cforn,:cpat,:cprod,:cservidor,:cuser,:mos,:fpag,:frec,:rcli,:rforn,:rpat,:rprod,:rpag,:rrec,
  #presence: true










end
