package Example::StatsLogger;

# This module implements a simple hook that copies a user's stats into their home directory before
# they are rotated out.

# There are two major parts to a standard hook:
#  * The function used to tell the hooks sytstem how it works (the describe method)
#  * The Hooked code (in this case, the copy_logfiles method)

# The Describe Method
# This hook can be activated by executing '/usr/local/cpanel/bin/manage_hooks add module Example::StatsLogger`.
# At this point the describe method within this hook is invoked, the data structure that is returned is parsed 
# and placed into the hooks database.

# The Hooked Code
# This is the code where a hook's logic is kept.  The hook system is made aware of a hook by the information returned 
# from describe()  It is passed 2 parameters:
#   * The Context - Describes where the hook is being called from
#   * Args - The data passed from the code calling it
# These two pieces of data are documented in full in the "Hook insertion point" documentation, available at 
# url/that/does not/exist/yet

# In this example, the hook system will proxy the attributes related to domlog processing to copy_logfiles() so the 
# respective log files can be copied to the user's homedirectory when domain log statistics run.  Because the
# describe() hash element 'stage' is defined as 'post' the hook action will occur after the various statistic engines 
# parse the log files but prior to the end the larger cPanel operation.

# In some hook insertion points, it's important to note which user is executing the hook.  In this case, the hook is 
# run by the user itself rather than executed by root.  In cases where you are running code as root, it is important
# to not perform file operations on files under the user's control, the Cpanel::AccessIds module offers a few methods
# that address this concern.

# This is the describe subroutine.
# This subroutine is used by /usr/local/cpanel/bin/manage_hooks to populated the hooks database. Every standard hook 
# MUST have this subroutine.
sub describe {
	my $hooks = [
		{
			'namespace' => 'Stats', # define the namespace that the insertion point exists in
            'function'  => 'RunUser', # define the function
            'hook'      => 'Example::StatsLogger::copy_logfiles', # define the subroutine to execute
            'stage'     => 'post', # Define the stage of the function that the hook should be executed from
		},
	];
	return $hooks;
}

# This is the actual hooked code.
sub copy_logfiles {
	my ( $context, $args ) = @_;
    my $homedir = $args->{'homedir'};   # Grab the user's home directory out of the data passed to the hook
    foreach $log_ref ( @{ $args->{'logfiledesc'} } ) {  # Iterate over each domain that was processed
        my $access_log      = $log_ref->{'logfile'};
        my $backup_location = "$homedir/domain_logs/" . $log_ref->{'domain'} . '.' . time();
        if ( !-e "$homedir/domain_logs" ) {
            mkdir "$homedir/domain_logs";
        }
        print "Backing up log files for " . $log_ref->{'domain'} . " from $access_log to $backup_location\n";
        File::Copy::copy( $access_log, $backup_location ) || print STDERR $! . "\n";
    }
	return 1;
}

1;