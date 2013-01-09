# == Define: logstash::input::generator
#
#   This is the threadable class for logstash inputs. Use this class in
#   your inputs if it can support multiple threads
#
#
# === Parameters
#
# [*add_field*] 
#   Add a field to an event
#   Value type is hash
#   Default value: {}
#   This variable is optional
#
# [*count*] 
#   Set how many messages should be generated.  The default, 0, means
#   generate an unlimited number of events.
#   Value type is integer
#   Default value: 0
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
# [*lines*] 
#   The lines to emit, in order. This option cannot be used with the
#   'message' setting.  Example:  input {   generator {     lines =&gt; [ 
#   "line 1",       "line 2",       "line 3"     ]   }    # Emit all lines
#   3 times.   count =&gt; 3 }   The above will emit "line 1" then "line
#   2" then "line", then "line 1", etc...
#   Value type is array
#   Default value: None
#   This variable is optional
#
# [*message*] 
#   The message string to use in the event.  If you set this to 'stdin'
#   then this plugin will read a single line from stdin and use that as
#   the message string for every event.  Otherwise, this value will be
#   used verbatim as the event message.
#   Value type is string
#   Default value: "Hello world!"
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
#  http://logstash.net/docs/1.1.5/inputs/generator
#
#  Need help? http://logstash.net/docs/1.1.5/learn
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define logstash::input::generator(
  $type,
  $message        = '',
  $debug          = '',
  $format         = '',
  $lines          = '',
  $count          = '',
  $message_format = '',
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

  if $lines {
    validate_array($lines)
    $arr_lines = join($lines, "', '")
    $opt_lines = "  lines => ['${arr_lines}']\n"
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

  if $count {
    if ! ($count in integer) {
      fail("\"${count}\" is not a valid count parameter value")
    } else {
      $opt_count = "  count => \"${count}\"\n"
    }
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

  if $message { 
    validate_string($message)
    $opt_message = "  message => \"${message}\"\n"
  }

  if $message_format { 
    validate_string($message_format)
    $opt_message_format = "  message_format => \"${message_format}\"\n"
  }

  if $type { 
    validate_string($type)
    $opt_type = "  type => \"${type}\"\n"
  }

  #### Write config file

  file { "${logstash::params::configdir}/input_generator_${name}":
    ensure  => present,
    content => "input {\n generator {\n${opt_add_field}${opt_count}${opt_debug}${opt_format}${opt_lines}${opt_message}${opt_message_format}${opt_tags}${opt_threads}${opt_type} }\n}\n",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Class['logstash::service'],
    require => Class['logstash::package', 'logstash::config']
  }
}
