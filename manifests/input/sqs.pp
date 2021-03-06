# == Define: logstash::input::sqs
#
#   This is the threadable class for logstash inputs. Use this class in
#   your inputs if it can support multiple threads
#
#
# === Parameters
#
# [*access_key*] 
#   AWS access key. Must have the appropriate permissions.
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*add_field*] 
#   Add a field to an event
#   Value type is hash
#   Default value: {}
#   This variable is optional
#
# [*debug*] 
#   Set this to true to enable debugging on an input.
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*format*] 
#   The format of input data (plain, json, json_event)
#   Value can be any of: "plain", "json", "json_event"
#   Default value: None
#   This variable is optional
#
# [*message_format*] 
#   If format is "json", an event sprintf string to build what the display
#   @message should be given (defaults to the raw JSON). sprintf format
#   strings look like %{fieldname} or %{@metadata}.  If format is
#   "json_event", ALL fields except for @type are expected to be present.
#   Not receiving all fields will cause unexpected results.
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*queue*] 
#   Name of the SQS Queue name to pull messages from. Note that this is
#   just the name of the queue, not the URL or ARN.
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*secret_key*] 
#   AWS secret key. Must have the appropriate permissions.
#   Value type is string
#   Default value: None
#   This variable is required
#
# [*tags*] 
#   Add any number of arbitrary tags to your event.  This can help with
#   processing later.
#   Value type is array
#   Default value: None
#   This variable is optional
#
# [*threads*] 
#   Set this to the number of threads you want this input to spawn. This
#   is the same as declaring the input multiple times
#   Value type is number
#   Default value: 1
#   This variable is optional
#
# [*type*] 
#   Label this input with a type. Types are used mainly for filter
#   activation.  If you create an input with type "foobar", then only
#   filters which also have type "foobar" will act on them.  The type is
#   also stored as part of the event itself, so you can also use the type
#   to search for in the web interface.
#   Value type is string
#   Default value: None
#   This variable is required
#
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
#  Extra information about this input can be found at:
#  http://logstash.net/docs/1.1.5/inputs/sqs
#
#  Need help? http://logstash.net/docs/1.1.5/learn
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define logstash::input::sqs(
  $access_key,
  $type,
  $secret_key,
  $queue,
  $message_format = '',
  $format         = '',
  $debug          = '',
  $tags           = '',
  $threads        = '',
  $add_field      = '',
) {

  require logstash::params

  #### Validate parameters
  if $tags {
    validate_array($tags)
    $arr_tags = join($tags, "', '")
    $opt_tags = "  tags => ['${arr_tags}']\n"
  }

  if $debug {
    validate_bool($debug)
    $opt_debug = "  debug => ${debug}\n"
  }

  if $add_field {
    validate_hash($add_field)
    $arr_add_field = inline_template('<%= add_field.to_a.flatten.inspect %>')
    $opt_add_field = "  add_field => ${arr_add_field}\n"
  }

  if $threads {
    if ! is_numeric($threads) {
      fail("\"${threads}\" is not a valid threads parameter value")
    }
  }

  if $format {
    if ! ($format in ['plain', 'json', 'json_event']) {
      fail("\"${format}\" is not a valid format parameter value")
    } else {
      $opt_format = "  format => \"${format}\"\n"
    }
  }

  if $queue { 
    validate_string($queue)
    $opt_queue = "  queue => \"${queue}\"\n"
  }

  if $secret_key { 
    validate_string($secret_key)
    $opt_secret_key = "  secret_key => \"${secret_key}\"\n"
  }

  if $message_format { 
    validate_string($message_format)
    $opt_message_format = "  message_format => \"${message_format}\"\n"
  }

  if $access_key { 
    validate_string($access_key)
    $opt_access_key = "  access_key => \"${access_key}\"\n"
  }

  if $type { 
    validate_string($type)
    $opt_type = "  type => \"${type}\"\n"
  }

  #### Write config file

  file { "${logstash::params::configdir}/input_sqs_${name}":
    ensure  => present,
    content => "input {\n sqs {\n${opt_access_key}${opt_add_field}${opt_debug}${opt_format}${opt_message_format}${opt_queue}${opt_secret_key}${opt_tags}${opt_threads}${opt_type} }\n}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['logstash::service'],
    require => Class['logstash::package', 'logstash::config']
  }
}
