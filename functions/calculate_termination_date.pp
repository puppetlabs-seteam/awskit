# Calculate a termination date from the current time and the $lifetime parameter
# lifetime is of the format <integer><w|d|h|m>, for example "1d" or "3w"
# The $start parameter is the starting timestamp as basis for the lifetime calculation
# defaults to the current timestamp (only needed for unit testing)
function awskit::calculate_termination_date(
  String    $lifetime,
  Timestamp $start = Timestamp.new(),
  ) >> String {

  # validate lifetime
  if $lifetime =~ /^([0-9]+)(w|d|h|m)$/ {
    $length = Integer($1)
    $unit = $2
    case $unit {
      'w': { $duration = Timespan.new(days => 7*$length) }
      'd': { $duration = Timespan.new(days => $length) }
      'h': { $duration = Timespan.new(hours => $length) }
      'm': { $duration = Timespan.new(minutes => $length) }
    }
    $termination_date = $start + $duration
    notice("Start timestamp: ${start}")
    notice("Lifetime: ${lifetime}")
    notice("Termination date: ${termination_date}")
  } else {
    fail("Invalid lifetime: ${lifetime}")
  }
  # see https://puppet.com/docs/puppet/5.5/function.html#timestamp-specific-flags 
  # for strftime flag documentation
  strftime($termination_date, '%FT%T.%L000+00:00')
}
