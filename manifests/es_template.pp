class logstash::es_template(
  $match_pattern                  = 'logstash-*',
  $number_of_shards               = 5,
  $number_of_replicas             = 1,
  $query_default_field            = '@message',
  $store_compress                 = true,
  $all_disabled                   = true,
  $source_compress                = true,
  $elasticsearch_user             = 'elasticsearch',
  $elasticsearch_group            = 'elasticsearch',
  $elasticsearch_config_path      = '/etc/elasticsearch'
) {
  file { "${elasticsearch_config_path}/templates":
    ensure      => directory,
    mode        => '0644',
    owner       => $elasticsearch_user,
    group       => $elasticsearch_group,
    require     => Class['elasticsearch'],
  }

  file { "${elasticsearch_config_path}/templates/logstash.json":
    ensure      => present,
    mode        => '0644',
    owner       => $elasticsearch_user,
    group       => $elasticsearch_group,
    content     => template("${module_name}/elasticsearch_template.json.erb"),
    require     => [Class['elasticsearch'],File["${elasticsearch_config_path}/templates"]],
  }
}
