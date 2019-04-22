require 'net/http'
require 'json'
require 'base64'
require 'set'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
