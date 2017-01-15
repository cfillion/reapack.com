#!/usr/bin/env ruby

require 'openssl'
require 'rack/utils'
require 'stringio'

ROOT = File.dirname File.dirname(__FILE__)
DATAFILE = File.join ROOT, 'data', 'releases.yml'
SCRIPT = File.join ROOT, 'update.rb'
KEEPENV = %w{USER HOME PATH LANG}
RATELIMIT = 3600 * 5

# https://developer.github.com/webhooks/securing/
def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(
    OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'].to_s, payload_body)
  return Rack::Utils.secure_compare signature, ENV['HTTP_X_HUB_SIGNATURE'].to_s
end

def last_update
  if File.exist? DATAFILE
    File.mtime DATAFILE
  else
    Time.new 0
  end
end

def reply(status, message)
  puts 'content-type: text/plain'
  puts 'status: %d' % status
  puts
  puts message
  return 0
end

def exec(out, *args)
  bundle = File.join Gem.user_dir, 'bin', 'bundle'
  env = Hash[KEEPENV.map {|key| [key, ENV[key]] }]
  opts = {:err=>[:child, :out], :unsetenv_others => true, :chdir => ROOT}

  IO.popen env, [bundle, 'exec', *args], opts do |io|
    io.each {|line| out.puts line }
  end

  $?.to_i == 0
end

exit reply(500, 'No secret token set') unless ENV['SECRET_TOKEN']
exit reply(405, 'Bad method') unless ENV['REQUEST_METHOD'] == 'POST'
exit reply(200, 'Pong') if ENV['HTTP_X_GITHUB_EVENT'] == 'ping'
exit reply(403, 'Bad event') unless ENV['HTTP_X_GITHUB_EVENT'] == 'release'
exit reply(429, 'Firewalled') if last_update > Time.now - RATELIMIT
exit reply(401, 'Bad signature') unless verify_signature $stdin.read

out = StringIO.new

if exec(out, SCRIPT, 'releases') && exec(out, 'middleman', 'build')
  reply 200, 'OK'
else
  reply 500, 'Failed'
end

out.rewind
puts "\n"
puts out.read
