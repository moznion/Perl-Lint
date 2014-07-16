package Perl::Lint::Keywords;
use strict;
use warnings;
use B::Keywords;
use parent qw/Exporter/;
our @EXPORT = qw/
    is_perl_builtin
    is_perl_builtin_which_provide_list_context
    is_perl_builtin_which_take_multiple_arguments
    is_perl_bareword
    is_perl_pragma
/;

my %builtin_func_map;
for my $func (@B::Keywords::Functions) {
    $builtin_func_map{$func} = 1;
}

my %bareword_map;
for my $bareword (@B::Keywords::Barewords) {
    $bareword_map{$bareword} = 1;
}

# perldoc -uT perlfunc | grep '=item.*LIST' | sed 's/(//' | awk '{print $2 " => 1,"}' | uniq
my %builtin_func_which_provide_list_context_map = (
    chmod    => 1,
    chomp    => 1,
    chop     => 1,
    chown    => 1,
    die      => 1,
    do       => 1,
    exec     => 1,
    formline => 1,
    grep     => 1,
    import   => 1,
    join     => 1,
    kill     => 1,
    map      => 1,
    no       => 1,
    open     => 1,
    pack     => 1,
    print    => 1,
    printf   => 1,
    push     => 1,
    reverse  => 1,
    say      => 1,
    sort     => 1,
    splice   => 1,
    sprintf  => 1,
    syscall  => 1,
    system   => 1,
    tie      => 1,
    unlink   => 1,
    unshift  => 1,
    use      => 1,
    utime    => 1,
    warn     => 1,
);

# perldoc -uT perlfunc | grep '=item.*[A-Z],' | awk '{print $2 " => 1,"}' | uniq
my %builtin_func_which_take_multiple_arguments_map = (
    accept        => 1,
    atan2         => 1,
    bind          => 1,
    binmode       => 1,
    bless         => 1,
    connect       => 1,
    crypt         => 1,
    dbmopen       => 1,
    fcntl         => 1,
    flock         => 1,
    formline      => 1,
    getpriority   => 1,
    getservbyname => 1,
    gethostbyaddr => 1,
    getnetbyaddr  => 1,
    getservbyport => 1,
    getsockopt    => 1,
    grep          => 1,
    index         => 1,
    ioctl         => 1,
    join          => 1,
    kill          => 1,
    link          => 1,
    listen        => 1,
    map           => 1,
    mkdir         => 1,
    msgctl        => 1,
    msgget        => 1,
    msgrcv        => 1,
    msgsnd        => 1,
    open          => 1,
    opendir       => 1,
    pack          => 1,
    pipe          => 1,
    printf        => 1,
    push          => 1,
    read          => 1,
    recv          => 1,
    rename        => 1,
    rindex        => 1,
    seek          => 1,
    seekdir       => 1,
    select        => 1,
    semctl        => 1,
    semget        => 1,
    semop         => 1,
    send          => 1,
    setpgrp       => 1,
    setpriority   => 1,
    setsockopt    => 1,
    shmctl        => 1,
    shmget        => 1,
    shmread       => 1,
    shmwrite      => 1,
    shutdown      => 1,
    socket        => 1,
    socketpair    => 1,
    splice        => 1,
    split         => 1,
    sprintf       => 1,
    substr        => 1,
    symlink       => 1,
    syscall       => 1,
    sysopen       => 1,
    sysread       => 1,
    sysseek       => 1,
    syswrite      => 1,
    tie           => 1,
    truncate      => 1,
    unpack        => 1,
    unshift       => 1,
    vec           => 1,
    waitpid       => 1,
    %builtin_func_which_provide_list_context_map,
);

# from `Module::CoreList->find_modules(qr/^[a-z].*/);`
# NOTE the above script is a bit slow, so results of this are hardcoded
my %pragma_map = (
    'arybase'                    => 1,
    'assertions'                 => 1,
    'assertions::activate'       => 1,
    'assertions::compat'         => 1,
    'attributes'                 => 1,
    'attrs'                      => 1,
    'autodie'                    => 1,
    'autodie::exception'         => 1,
    'autodie::exception::system' => 1,
    'autodie::hints'             => 1,
    'autodie::skip'              => 1,
    'autouse'                    => 1,
    'base'                       => 1,
    'bigint'                     => 1,
    'bignum'                     => 1,
    'bigrat'                     => 1,
    'blib'                       => 1,
    'bytes'                      => 1,
    'charnames'                  => 1,
    'constant'                   => 1,
    'deprecate'                  => 1,
    'diagnostics'                => 1,
    'encoding'                   => 1,
    'encoding::warnings'         => 1,
    'feature'                    => 1,
    'fields'                     => 1,
    'filetest'                   => 1,
    'if'                         => 1,
    'inc::latest'                => 1,
    'integer'                    => 1,
    'legacy'                     => 1,
    'less'                       => 1,
    'lib'                        => 1,
    'locale'                     => 1,
    'mro'                        => 1,
    'open'                       => 1,
    'ops'                        => 1,
    'overload'                   => 1,
    'overload::numbers'          => 1,
    'overloading'                => 1,
    'parent'                     => 1,
    'perlfaq'                    => 1,
    're'                         => 1,
    'sigtrap'                    => 1,
    'sort'                       => 1,
    'strict'                     => 1,
    'subs'                       => 1,
    'threads'                    => 1,
    'threads::shared'            => 1,
    'unicore::Name'              => 1,
    'utf8'                       => 1,
    'vars'                       => 1,
    'version'                    => 1,
    'vmsish'                     => 1,
    'warnings'                   => 1,
    'warnings::register'         => 1,
);

sub is_perl_builtin {
    my $key = shift;
    return if !$key;

    return exists $builtin_func_map{$key};
}

sub is_perl_builtin_which_provide_list_context {
    my $key = shift;
    return if !$key;

    return exists $builtin_func_which_provide_list_context_map{$key};
}

sub is_perl_builtin_which_take_multiple_arguments {
    my $key = shift;
    return if !$key;

    return exists $builtin_func_which_take_multiple_arguments_map{$key};
}

sub is_perl_bareword {
    my $key = shift;
    return if !$key;

    return exists $bareword_map{$key};
}

sub is_perl_pragma {
    my $key = shift;
    return if !$key;

    return exists $pragma_map{$key};
}

1;

