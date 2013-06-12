class logstash::plugins (
  $pluginpath        = $logstash::params::logstash_home,
) {
  file { "${pluginpath}/logstash":
    ensure        => 'directory',
    source        =>  "puppet:///${module_name}/plugins",
    recurse       => true,
  }
}
