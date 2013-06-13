# == Define: logstash::filter::storegeoip
#
#   The ip2store filter allows you to do general ip2storeations to fields that
#   are not included in the normal mutate filter.  NOTE: The functionality
#   provided by this plugin is likely to be merged into the 'mutate'
#   filter in future versions.
#
#
# === Parameters
#
# [*field*]
#   Change the content of the field to the specified value if the content
#   of another field is equal to the expected one.  Example:  filter {
#   ip2store =&gt; {     condrewriteother =&gt; [           "field_name",
#   "expected_value", "field_name_to_change", "value",
#   "field_name2", "expected_value2, "field_name_to_change2", "value2",
#   ....     ]   } }
#   Value type is array
#   Default value: None
#   This variable is optional
#
# [*target*]
#   Only handle events without any of these tags. Note this check is
#   additional to type and tags.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*service_bus_url*]
#   If this filter is successful, remove arbitrary tags from the event.
#   Tags can be dynamic and include parts of the event using the %{field}
#   syntax. Example:  filter {   myfilter {     remove_tag =&gt; [
#   "foo_%{somefield}" ]   } }   If the event has field "somefield" ==
#   "hello" this filter, on success, would remove the tag "foo_hello" if
#   it is present
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*api_key*]
#   If this filter is successful, remove arbitrary tags from the event.
#   Tags can be dynamic and include parts of the event using the %{field}
#   syntax. Example:  filter {   myfilter {     remove_tag =&gt; [
#   "foo_%{somefield}" ]   } }   If the event has field "somefield" ==
#   "hello" this filter, on success, would remove the tag "foo_hello" if
#   it is present
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*tags*]
#   Only handle events with all of these tags.  Note that if you specify a
#   type, the event must also match that type. Optional.
#   Value type is array
#   Default value: []
#   This variable is optional
#
# [*type*]
#   The type to act on. If a type is given, then this filter will only act
#   on messages with the same type. See any input plugin's "type"
#   attribute for more. Optional.
#   Value type is string
#   Default value: ""
#   This variable is optional
#
# [*order*]
#   The order variable decides in which sequence the filters are loaded.
#   Value type is number
#   Default value: 10
#   This variable is optional
#
#
# === Examples
#
#
#
#
# === Extra information
#
#  This define is created based on LogStash version 1.1.5
#  Extra information about this filter can be found at:
#  http://logstash.net/docs/1.1.5/filters/ip2store
#
#  Need help? http://logstash.net/docs/1.1.5/learn
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define logstash::filter::storegeoip(
  $field            = '',
  $target           = '',
  $service_bus_url  = '',
  $api_key          = '',
  $tags             = '',
  $type             = '',
  $order            = 10,
) {

  require logstash::params

  #### Validate parameters
  if $field {
    validate_string($field)
    $opt_field = "  field => \"${field}\"\n"
  }

  if $target {
    validate_string($target)
    $opt_target = "  target => \"${target}\"\n"
  }

  if $service_bus_url {
    validate_string($service_bus_url)
    $opt_service_bus_url = "  service_bus_url => \"${service_bus_url}\"\n"
  }

  if $api_key {
    validate_string($api_key)
    $opt_api_key = "  api_key => \"${api_key}\"\n"
  }

  if $tags {
    validate_array($tags)
    $arr_tags = join($tags, "', '")
    $opt_tags = "  tags => ['${arr_tags}']\n"
  }

  if $order {
    if ! is_numeric($order) {
      fail("\"${order}\" is not a valid order parameter value")
    }
  }

  if $type {
    validate_string($type)
    $opt_type = "  type => \"${type}\"\n"
  }

  #### Write config file

  file { "${logstash::params::configdir}/filter_${order}_storegeoip_${name}":
    ensure  => present,
    content => "filter {\n storegeoip {\n${opt_field}${opt_target}${opt_service_bus_url}${opt_api_key}${opt_tags}${opt_type} }\n}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['logstash::service'],
    require => Class['logstash::package', 'logstash::install']
  }
}
