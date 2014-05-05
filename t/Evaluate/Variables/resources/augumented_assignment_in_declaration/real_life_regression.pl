use strict;
my $exception_class = ($exception_class_for{$class} ||= $class->exception_class);
my $exception_class = $exception_class_for{$class} ||= $class->exception_class;
my $feature = ${*$ftp}{net_ftp_feature} ||= do { my @feat; @feat = map { /^\s+(.*\S)/ } $ftp->message if $ftp->_FEAT; \@feat; };
my $tests = $self->{tests} ||= {};
my $attr = $_[0]->{A}->{$attrName} ||= new XML::XQL::DirAttr (Parent => $self, Name => $attrName);
