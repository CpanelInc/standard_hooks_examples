This repo contains examples of how to use the Standardized Hooks system in cPanel & WHM.  These examples are designed to be as simple as possible while implementing Standardized Hooks in real-life scenarios.  Each module is well commented with quite a bit of information on how a feature works along with links to the documentation on the feature.

It is suggested that you review the Standardized Hooks documentation on http://sdk.cpanel.net/ before reviewing these files.

# INSTALLATION

WARNING: These hooks will modify the behavior of your cPanel & WHM installation, these should only be installed after the affects of using them is fully understood.  *This specifically applies to the "RollbackHook" module which will disable the ability to create accounts.*

To install these hooks, follow the following instructions:
> mkdir -p /var/cpanel/perl5/lib/Example
> cp /path/to/checked/out/modules/*pm /var/cpanel/perl5/lib/Example

Then to activate a hook:
> /usr/local/cpanel/bin/manage_hooks add module Example::$modulename

# Information on the Included Libraries

Each one of these modules implements a set of new functionality in cPanel & WHM.  These are intended to be implemented in the simplest way possible.

## Example::StatsLogger
This module implements a feature that will make it so a user's log files are copied into their home directory after statistics are processed.  This contains in-line information about; how a hook is inserted into the hooks database, the general structure of a hook module, and How to work with statistics processing through the hooks system.

## Example::PasswordLimitations
This module implements a very simple check to ensure that no passwords are created or set with a length less than 12 characters.  This module is a simple example of how to deny an event from occurring & and providing a custom error message.

## Example::RollbackHook
This module implements a rollback hook, which is a hook that contains logic to back itself out in case a subsequent hook fails.

This module contains quite a bit of information on how to use the Rollback Feature and how to enable the "Debug Mode" for the hooks system.

# Author & License information

These modules were developed by Matt Dees (matt@cpanel.net) at cPanel, Inc.
These are intended as examples and provided as is with no warrantee.  Use at your own risk.