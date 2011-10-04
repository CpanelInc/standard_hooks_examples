package Example::PasswordLimitations;

# This implements a custom check for a password where if the length is less than 12, it will deny the event from occuring.
# This should be considered a standard example of blocking an action from a hook.
#
# To block an action simply return a value of 0.  This value will indicate to the hooks sytem that the event should not be
# allowed to proceed.  In order for an action to be blocked, the hook insertion point (also called context) must indicate
# that it is blocking.  This is told to the underlying subroutine via the 'blocking' key in the $context hash.

sub passwd_length {
    my ( $context, $data ) = @_;
    # Return a 0 which denies the action & an error messsage if the password is under 12 characters
    return 0, 'passwords under 12 characters are not permitted.' if length $data->{'new_password'} < 12;
    # Return 1 indicating that the action is allowed
    return 1;
}

sub describe {
    my $hook = [
        {
            'namespace' => 'Passwd',
            'function'  => 'ChangePasswd',
            'stage'     => 'pre',
            'hook'      => 'Example::PasswordLimitations::passwd_length',
        },
    ];
    return $hook;
}

1;
