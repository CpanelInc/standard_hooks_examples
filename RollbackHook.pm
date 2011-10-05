package Example::RollbackHook;

use Cpanel::DataStore ();

# This module implements an example of a RollbackHook.
# Note: if this module is installed on your server, ACCOUNTS WILL NOT BE ABLE TO BE CREATED.

# In this example we will create a log defined by $account_log that specifies where we will store
# A YAML datastore of account information.  Along with this we will define a rollback hook to remove it
# another hook to display the contents of the log file.  finally a hook to deny the event from occuring
# so that the rollback code is triggered.

# The purpose of the rollback functionality is to allow your hook a way to back out the changes it made.
# This functionality is critical when writing hooks that deal with external systems, where you may be
# creating related resources that are only valid for successful cPanel account creation.

# Rollback hooks are code that can be executed after a hook is run and a subsequent hook fails.
# For Example:
# 1. Hook1 runs
# 2. Hook2 runs
# 3. Hook3 fails
#
# At this point,the standardized hooks sytem will iterate over previously run hooks and check for a
# 'rollback' attribute that points to another subroutine.  When the rollback functionality is in use,
# the order of execution will be:
# 1. Hook1 runs
# 2. Hook2 runs
# 3. Hook3 fails
# 4. Hook2 - no rollback function
# 5. Hook1 - execute rollback function
#
# For more information on Rollback hooks, please see the documentation at:
#    http://url/that/is/not/public/yet

# When working with this hook, it is suggested that you enable "debughooks" option in
# /var/cpanel/cpanel.config.  When # this option is enabled, the hooks system will output a bunch of
# extra information to /usr/local/cpanel/logs/error_log or STDERR (if used via a shell) about what hook
# points were passed, what hooks were run, what stage a hook is run in & what data is passed to a hook.

# This feature was used heavily in developing & testing the hooks system.
# See the documentation on how to use this feature at: http://url/that/does/not/exist/yet

# INSTALLATION INSTRUCTIONS:
#
# To see this in action on your server, `echo 'debughooks=2' >> /var/cpanel/cpanel.config`
# Save this file to /var/cpanel/perl5/lib/Example/RollbackHook.pm
# run `bin/manage_hooks add module Example::RollbackHook`
# tail -f /usr/local/cpanel/logs/error_log to watch the hooks roll by.

print STDERR "\n\n---\n
\tThe Example::RollbackHook module is installed on this server\n
\tACCOUNTS WILL NOT BE ABLE TO BE CREATED WITH THIS INSTALLED.\n
\tTo remove, please run '/usr/local/cpanel/bin/manage_hooks del module Example::RollbackHook'\n
---\n\n";

my $account_log   = '/root/accounts_log.yaml';
my $accounts_data = Cpanel::DataStore::load_ref($account_log);

# This is the hook that will actually be run.
sub add_account_to_datastore {
    my ( $context, $data ) = @_;

    # build data structure
    $accounts_data->{ $data->{'user'} } = $data;

    # save data
    Cpanel::DataStore::store_ref( $account_log, $accounts_data );

    return 1;
}

# This is the code that is executed after the account creation has been denied by deny_event().
sub remote_account_from_datastore {
    my ( $context, $data ) = @_;
    $accounts_data = Cpanel::DataStore::load_ref($account_log);    # reinstate db

    delete $accounts_data->{ $data->{'user'} };                    # Remove entry from db
    Cpanel::DataStore::store_ref( $account_log, $accounts_data );  # Save file

    return 1;
}

# Display the contents of the accounting file
sub print_contents_of_account_file {
    print STDERR "\nDISPLAYING CONTENTS OF $account_log\n\n";
    open( my $db_fh, '<', $account_log ) || return 0, 'Could not obtain lock on log file';
    while ( my $line = readline $db_fh ) {
        print STDERR $line;
    }
    close $db_fh;
    print STDERR "\n\nEND CONTENTS OF $account_log\n\n";
    return 1;
}

# This will ensure that the rollback logic is triggered.
# This will also ensure that accounts can never be created on this server
sub deny_event {
    return 0, 'This isn\'t allowed because without it, this example would not make a lot of sense';
}

sub describe {
    my $hook = [

        # Hook that contains that does something and allows it to be rolled back
        {
            'namespace' => 'Whostmgr',
            'function'  => 'Accounts::Create',
            'stage'     => 'pre',
            'hook'      => 'Example::RollbackHook::add_account_to_datastore',
            'rollback'  => 'Example::RollbackHook::remote_account_from_datastore',
            'weight'    => 1,                                                        # Ensure that this one is run first
        },
        {
            'namespace' => 'Whostmgr',
            'function'  => 'Accounts::Create',
            'stage'     => 'pre',
            'hook'      => 'Example::RollbackHook::print_contents_of_account_file',
            'weight'    => 2,                                                         # Display the contents of the file.
        },

        # Hook that will always fail so that the rollback code is triggered, remove the hash under
        # this comment to allow an account log to be actually created.
        {
            'namespace' => 'Whostmgr',
            'function'  => 'Accounts::Create',
            'stage'     => 'pre',
            'hook'      => 'Example::RollbackHook::deny_event',
            #ensure that this is run after the hook that needs to be rolled back.
            'weight'    => 3,                                                       
        },
    ];
    return $hook;
}
1;
