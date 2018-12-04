const { exec } = require('child_process')

module.exports = function(content, map, meta) {
  let callback = this.async();

  let slimrb = exec('bundle exec slimrb', (err, result) => {
    if(err)
      return callback(err);

    callback(null, result, map, meta);
  });

  slimrb.stdin.write(content);
  slimrb.stdin.end();
}
