worker_processes Integer(ENV["WEB_CONCURRENCY"] || 6)
timeout 30
preload_app true
@dj_pid = nil

before_fork do |server, worker|
  @dj_pid ||= spawn('bundle exec rake jobs:work')

  Signal.trap 'TERM' do
    puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|

  Signal.trap 'TERM' do
    puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  end

  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end
