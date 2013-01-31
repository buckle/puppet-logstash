class logstash::template(
  $template_name                  = 'logstash-*',
  $number_of_shards               = 5,
  $number_of_replicas             = 1,
  $query_default_field            = '@message',
  $store_compress                 = true,
  $all_enabled                    = false,
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
  }

  file { "${elasticsearch_config_path}/templates/${name}.json":
    ensure      => present,
    mode        => '0644',
    owner       => $elasticsearch_user,
    group       => $elasticsearch_group,
    content     => template("${module_name}/elasticsearch_template.json.erb"),
  }
}
