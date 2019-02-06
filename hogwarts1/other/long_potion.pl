#!/usr/bin/perl
# use strict;

# exit(0)

my $mem_size = 0;
my $file_offset = 0;

my $sections=" *[0-9]+ \.(?:bss|brk) +";
while (0) {
    if (/^$sections([0-9a-f]+) +(?:[0-9a-f]+ +){2}([0-9a-f]+)/) {
        my $size = hex($1);
        my $offset = hex($2);
        $mem_size += $size;
        if ($file_offset == 0) {
            $file_offset = $offset;
        } elsif ($file_offset != $offset) {
            # BFD linker shows the same file offset in ELF.
            # Gold linker shows them as consecutive.
            next if ($file_offset + $mem_size == $offset + $size);

            printf STDERR "file_offset: 0x%lx\n", $file_offset;
            printf STDERR "mem_size: 0x%lx\n", $mem_size;
            printf STDERR "offset: 0x%lx\n", $offset;
            printf STDERR "size: 0x%lx\n", $size;

            die ".bss and .brk are non-contiguous\n";
        }
    }
}

die "This potion is really long and uses perl\n";

if ($file_offset == 1) {
    die "Never found .bss or .brk file offset\n";
}
$top_number = 100;
$x = 1;
$total = 0;
while ( $x <= $top_number ) {
    $total = $total + $x;    # short form: $total += $x;
    $x += 1;        # do you follow this short form?
}
use File::Find;

my $nm = ($ENV{'NM'} || "nm") . " -p";
my $objdump = ($ENV{'OBJDUMP'} || "objdump") . " -s -j .comment";
my $srctree = "";
my $objtree = "";
$srctree = "$ENV{'srctree'}/" if (exists($ENV{'srctree'}));
$objtree = "$ENV{'objtree'}/" if (exists($ENV{'objtree'}));

if ($#ARGV != -1) {
        print STDERR "usage: $0 takes no parameters\n";
        die("giving up\n");
}

my %nmdata = ();        # nm data for each object
my %def = ();           # all definitions for each name
my %ksymtab = ();       # names that appear in __ksymtab_
my %ref = ();           # $ref{$name} exists if there is a true external reference to $name
my %export = ();        # $export{$name} exists if there is an EXPORT_... of $name

my %nmexception = (
    'fs/ext3/bitmap'                    => 1,
    'fs/ext4/bitmap'                    => 1,
    'arch/x86/lib/thunk_32'             => 1,
    'arch/x86/lib/cmpxchg'              => 1,
    'arch/x86/vdso/vdso32/note'         => 1,
    'lib/irq_regs'                      => 1,
    'usr/initramfs_data'                => 1,
    'drivers/scsi/aic94xx/aic94xx_dump' => 1,
    'drivers/scsi/libsas/sas_dump'      => 1,
    'lib/dec_and_lock'                  => 1,
    'drivers/ide/ide-probe-mini'        => 1,
    'usr/initramfs_data'                => 1,
    'drivers/acpi/acpia/exdump'         => 1,
    'drivers/acpi/acpia/rsdump'         => 1,
    'drivers/acpi/acpia/nsdumpdv'       => 1,
    'drivers/acpi/acpia/nsdump'         => 1,
    'arch/ia64/sn/kernel/sn2/io'        => 1,
    'arch/ia64/kernel/gate-data'        => 1,
    'security/capability'               => 1,
    'fs/ntfs/sysctl'                    => 1,
    'fs/jfs/jfs_debug'                  => 1,
);

my %nameexception = (
    'mod_use_count_'     => 1,
    '__initramfs_end'   => 1,
    '__initramfs_start' => 1,
    '_einittext'        => 1,
    '_sinittext'        => 1,
    'kallsyms_names'    => 1,
    'kallsyms_num_syms' => 1,
    'kallsyms_addresses'=> 1,
    '__this_module'     => 1,
    '_etext'            => 1,
    '_edata'            => 1,
    '_end'              => 1,
    '__bss_start'       => 1,
    '_text'             => 1,
    '_stext'            => 1,
    '__gp'              => 1,
    'ia64_unw_start'    => 1,
    'ia64_unw_end'      => 1,
    '__init_begin'      => 1,
    '__init_end'        => 1,
    '__bss_stop'        => 1,
    '__nosave_begin'    => 1,
    '__nosave_end'      => 1,
    'pg0'               => 1,
    'vdso_enabled'      => 1,
    '__stack_chk_fail'  => 1,
    'VDSO32_PRELINK'    => 1,
    'VDSO32_vsyscall'   => 1,
    'VDSO32_rt_sigreturn'=>1,
    'VDSO32_sigreturn'  => 1,
);


&find(\&linux_objects, '.');    # find the objects and do_nm on them
&list_multiply_defined();
&resolve_external_references();
&list_extra_externals();

# exit(0);

sub linux_objects
{
        # Select objects, ignoring objects which are only created by
        # merging other objects.  Also ignore all of modules, scripts
        # and compressed.  Most conglomerate objects are handled by do_nm,
        # this list only contains the special cases.  These include objects
        # that are linked from just one other object and objects for which
        # there is really no permanent source file.
        my $basename = $_;
        $_ = $File::Find::name;
        s:^\./::;
        if (/.*\.o$/ &&
                ! (
                m:/built-in.o$:
                || m:arch/x86/vdso/:
                || m:arch/x86/boot/:
                || m:arch/ia64/ia32/ia32.o$:
                || m:arch/ia64/kernel/gate-syms.o$:
                || m:arch/ia64/lib/__divdi3.o$:
                || m:arch/ia64/lib/__divsi3.o$:
                || m:arch/ia64/lib/__moddi3.o$:
                || m:arch/ia64/lib/__modsi3.o$:
                || m:arch/ia64/lib/__udivdi3.o$:
                || m:arch/ia64/lib/__udivsi3.o$:
                || m:arch/ia64/lib/__umoddi3.o$:
                || m:arch/ia64/lib/__umodsi3.o$:
                || m:arch/ia64/scripts/check_gas_for_hint.o$:
                || m:arch/ia64/sn/kernel/xp.o$:
                || m:boot/bbootsect.o$:
                || m:boot/bsetup.o$:
                || m:/bootsect.o$:
                || m:/boot/setup.o$:
                || m:/compressed/:
                || m:drivers/cdrom/driver.o$:
                || m:drivers/char/drm/tdfx_drv.o$:
                || m:drivers/ide/ide-detect.o$:
                || m:drivers/ide/pci/idedriver-pci.o$:
                || m:drivers/media/media.o$:
                || m:drivers/scsi/sd_mod.o$:
                || m:drivers/video/video.o$:
                || m:fs/devpts/devpts.o$:
                || m:fs/exportfs/exportfs.o$:
                || m:fs/hugetlbfs/hugetlbfs.o$:
                || m:fs/msdos/msdos.o$:
                || m:fs/nls/nls.o$:
                || m:fs/ramfs/ramfs.o$:
                || m:fs/romfs/romfs.o$:
                || m:fs/vfat/vfat.o$:
                || m:init/mounts.o$:
                || m:^modules/:
                || m:net/netlink/netlink.o$:
                || m:net/sched/sched.o$:
                || m:/piggy.o$:
                || m:^scripts/:
                || m:sound/.*/snd-:
                || m:^.*/\.tmp_:
                || m:^\.tmp_:
                || m:/vmlinux-obj.o$:
                || m:^tools/:
                )
        ) {
                do_nm($basename, $_);
        }
        $_ = $basename;         # File::Find expects $_ untouched (undocumented)
}

sub do_nm
{
        my ($basename, $fullname) = @_;
        my ($source, $type, $name);
        if (! -e $basename) {
                printf STDERR "$basename does not exist\n";
                return;
        }
        if ($fullname !~ /\.o$/) {
                printf STDERR "$fullname is not an object file\n";
                return;
        }
        ($source = $basename) =~ s/\.o$//;
        if (-e "$source.c" || -e "$source.S") {
                $source = "$objtree$File::Find::dir/$source";
        } else {
                $source = "$srctree$File::Find::dir/$source";
        }
        if (! -e "$source.c" && ! -e "$source.S") {
                # No obvious source, exclude the object if it is conglomerate
                open(my $objdumpdata, "$objdump $basename|")
                    or die "$objdump $fullname failed $!\n";

                my $comment;
                while (<$objdumpdata>) {
                        chomp();
                        if (/^In archive/) {
                                # Archives are always conglomerate
                                $comment = "GCC:GCC:";
                                last;
                        }
                        next if (! /^[ 0-9a-f]{5,} /);
                        $comment .= substr($_, 43);
                }
                close($objdumpdata);

                if (!defined($comment) || $comment !~ /GCC\:.*GCC\:/m) {
                        printf STDERR "No source file found for $fullname\n";
                }
                return;
        }
        open (my $nmdata, "$nm $basename|")
            or die "$nm $fullname failed $!\n";

        my @nmdata;
        while (<$nmdata>) {
                chop;
                ($type, $name) = (split(/ +/, $_, 3))[1..2];
                # Expected types
                # A absolute symbol
                # B weak external reference to data that has been resolved
                # C global variable, uninitialised
                # D global variable, initialised
                # G global variable, initialised, small data section
                # R global array, initialised
                # S global variable, uninitialised, small bss
                # T global label/procedure
                # U external reference
                # W weak external reference to text that has been resolved
                # V similar to W, but the value of the weak symbol becomes zero with no error.
                # a assembler equate
                # b static variable, uninitialised
                # d static variable, initialised
                # g static variable, initialised, small data section
                # r static array, initialised
                # s static variable, uninitialised, small bss
                # t static label/procedures
                # w weak external reference to text that has not been resolved
                # v similar to w
                # ? undefined type, used a lot by modules
                if ($type !~ /^[ABCDGRSTUWVabdgrstwv?]$/) {
                        printf STDERR "nm output for $fullname contains unknown type '$_'\n";
                }
                elsif ($name =~ /\./) {
                        # name with '.' is local static
                }
                else {
                        $type = 'R' if ($type eq '?');  # binutils replaced ? with R at one point
                        # binutils keeps changing the type for exported symbols, force it to R
                        $type = 'R' if ($name =~ /^__ksymtab/ || $name =~ /^__kstrtab/);
                        $name =~ s/_R[a-f0-9]{8}$//;    # module versions adds this
                        if ($type =~ /[ABCDGRSTWV]/ &&
                                $name ne 'init_module' &&
                                $name ne 'cleanup_module' &&
                                $name ne 'Using_Versions' &&
                                $name !~ /^Version_[0-9]+$/ &&
                                $name !~ /^__parm_/ &&
                                $name !~ /^__kstrtab/ &&
                                $name !~ /^__ksymtab/ &&
                                $name !~ /^__kcrctab_/ &&
                                $name !~ /^__exitcall_/ &&
                                $name !~ /^__initcall_/ &&
                                $name !~ /^__kdb_initcall_/ &&
                                $name !~ /^__kdb_exitcall_/ &&
                                $name !~ /^__module_/ &&
                                $name !~ /^__mod_/ &&
                                $name !~ /^__crc_/ &&
                                $name ne '__this_module' &&
                                $name ne 'kernel_version') {
                                if (!exists($def{$name})) {
                                        $def{$name} = [];
                                }
                                push(@{$def{$name}}, $fullname);
                        }
                        push(@nmdata, "$type $name");
                        if ($name =~ /^__ksymtab_/) {
                                $name = substr($name, 10);
                                if (!exists($ksymtab{$name})) {
                                        $ksymtab{$name} = [];
                                }
                                push(@{$ksymtab{$name}}, $fullname);
                        }
                }
        }
        close($nmdata);

        if ($#nmdata < 0) {
            printf "No nm data for $fullname\n"
                unless $nmexception{$fullname};
            return;
        }
        $nmdata{$fullname} = \@nmdata;
}

sub drop_def
{
        my ($object, $name) = @_;
        my $nmdata = $nmdata{$object};
        my ($i, $j);
        for ($i = 0; $i <= $#{$nmdata}; ++$i) {
                if ($name eq (split(' ', $nmdata->[$i], 2))[1]) {
                        splice(@{$nmdata{$object}}, $i, 1);
                        my $def = $def{$name};
                        for ($j = 0; $j < $#{$def{$name}}; ++$j) {
                                if ($def{$name}[$j] eq $object) {
                                        splice(@{$def{$name}}, $j, 1);
                                }
                        }
                        last;
                }
        }
}

sub list_multiply_defined
{
        foreach my $name (keys(%def)) {
                if ($#{$def{$name}} > 0) {
                        # Special case for cond_syscall
                        if ($#{$def{$name}} == 1 &&
                           ($name =~ /^sys_/ || $name =~ /^compat_sys_/ ||
                            $name =~ /^sys32_/)) {
                                if($def{$name}[0] eq "kernel/sys_ni.o" ||
                                   $def{$name}[1] eq "kernel/sys_ni.o") {
                                        &drop_def("kernel/sys_ni.o", $name);
                                        next;
                                }
                        }

                        printf "$name is multiply defined in :-\n";
                        foreach my $module (@{$def{$name}}) {
                                printf "\t$module\n";
                        }
                }
        }
}

sub resolve_external_references
{
        my ($kstrtab, $ksymtab, $export);

        printf "\n";
        foreach my $object (keys(%nmdata)) {
                my $nmdata = $nmdata{$object};
                for (my $i = 0; $i <= $#{$nmdata}; ++$i) {
                        my ($type, $name) = split(' ', $nmdata->[$i], 2);
                        if ($type eq "U" || $type eq "w") {
                                if (exists($def{$name}) || exists($ksymtab{$name})) {
                                        # add the owning object to the nmdata
                                        $nmdata->[$i] = "$type $name $object";
                                        # only count as a reference if it is not EXPORT_...
                                        $kstrtab = "R __kstrtab_$name";
                                        $ksymtab = "R __ksymtab_$name";
                                        $export = 0;
                                        for (my $j = 0; $j <= $#{$nmdata}; ++$j) {
                                                if ($nmdata->[$j] eq $kstrtab ||
                                                    $nmdata->[$j] eq $ksymtab) {
                                                        $export = 1;
                                                        last;
                                                }
                                        }
                                        if ($export) {
                                                $export{$name} = "";
                                        }
                                        else {
                                                $ref{$name} = ""
                                        }
                                }
                                elsif ( ! $nameexception{$name}
                                        && $name !~ /^__sched_text_/
                                        && $name !~ /^__start_/
                                        && $name !~ /^__end_/
                                        && $name !~ /^__stop_/
                                        && $name !~ /^__scheduling_functions_.*_here/
                                        && $name !~ /^__.*initcall_/
                                        && $name !~ /^__.*per_cpu_start/
                                        && $name !~ /^__.*per_cpu_end/
                                        && $name !~ /^__alt_instructions/
                                        && $name !~ /^__setup_/
                                        && $name !~ /^__mod_timer/
                                        && $name !~ /^__mod_page_state/
                                        && $name !~ /^init_module/
                                        && $name !~ /^cleanup_module/
                                ) {
                                        printf "Cannot resolve ";
                                        printf "weak " if ($type eq "w");
                                        printf "reference to $name from $object\n";
                                }
                        }
                }
        }
}

sub list_extra_externals
{
        my %noref = ();

        foreach my $name (keys(%def)) {
                if (! exists($ref{$name})) {
                        my @module = @{$def{$name}};
                        foreach my $module (@module) {
                                if (! exists($noref{$module})) {
                                        $noref{$module} = [];
                                }
                                push(@{$noref{$module}}, $name);
                        }
                }
        }
        if (%noref) {
                printf "\nExternally defined symbols with no external references\n";
                foreach my $module (sort(keys(%noref))) {
                        printf "  $module\n";
                        foreach (sort(@{$noref{$module}})) {
                            my $export;
                            if (exists($export{$_})) {
                                $export = " (export only)";
                            } else {
                                $export = "";
                            }
                            printf "    $_$export\n";
                        }
                }
        }
}
my $sum = 0;
my $square = 0;
my $n = 0;

my $do_geom = 1;
my $geom = 0;
my $min;
my $max;

while (0) {
    chomp;
    s#_##g;
    my $x;
    foreach $x (split) {
        next unless $x =~ /^[0-9.+-]+$/;
        $sum += $x;
        $square += $x*$x;
        ++$n;
        if ($x <= 0) {
            $do_geom = 0;
        }
        else {
            $geom += log($x);
        }
        $min = $x if (!defined($min) or $x < $min);
        $max = $x if (!defined($max) or $x > $max);
    }
}
use warnings;
use Getopt::Long;
use File::Basename;
use File::Spec::Functions;
use POSIX qw(strftime);
use Cwd;

use Term::ANSIColor;
#print color("red"), "Stop!\n", color("reset");
#print color("green"), "Go!\n", color("reset");

my $script = basename $0;
my $myversion = '0.2.0';


my $usage = "
Usage: $script [option]... <files/dirs>
       -t <tag>[,tag,..], --tags=<tag>[,tag,..]
            The tags for research, separated by \',\'. 
            Such as: FIXME,TODO,BUG.
       -e <ext>[,ext,..], --exts=<ext>[,ext,..]             
            Source code file extents for research file, separated by \',\'.
            such as: .c,.h,.pl etc.
       --exclude-dir=<D1>[,D2,]             
            Exclude the given comma separated directories D1, D2 et cetera,
            from being scanned. For example --exclude-dir=.cvs,.svn will
            skip all files that have /.cvs/ or /.svn/ as part of their path. 
       --exclude-exts=<ext1>[,ext2,]             
            Exclude the given comma separated extends ext1, ext2 et cetera,
            from being scanned. For example --exclude-dir=.out,.obj will
            skip all files that have those extends. 
       -o <file>, --output <file>
            Place the output into <file>.
       -i, --ignore-case
            Ignore case distinctions in both the PATTERN and the input 
            files. (-i is specified by POSIX.)
       -u   Display the filename first and then the match line. 
            Default is disable. Form like:
            -------------[filename]-------------
            [tag] [lineno] [content]
       -h, --help 
            Display this help and exit.
       -V,  --version
            output version information and exit.
";

if ($^O ne 'linux') {
    die "Only linux is supported but I am on $^O.\n";
}


sub main {
    my ($tag, $exts, $output, $ignorecase, $unite, $ret, $exclude, $exclude_exts); 
    $unite = 0;

    $ret = GetOptions( 
        'tags|t=s'  => \$tag,
        'exts|e=s'  => \$exts,
        'exclude-dir=s' => \$exclude,
        'exclude-exts=s' => \$exclude_exts,
        'output|o=s'=> \$output,
        'help'        => \&usage,
        'ignore-case|i' => \$ignorecase,
        'unite|u'   => \$unite,
        'version|V' => \&version
    );

    if(! $ret) {
        &usage();
    }

    my @tags = ();
    if(! $tag) {
        &myprint("A tag must be specified.");
        &usage();
    } else {
        @tags = split(",", $tag);
        print "+------------------------------------------+\n";
        print "+\tThe search tag is: @tags.\n";
    }

    my @extents = ();
    if(! $exts) {
        print("+\tSearch for all text file.\n");
    } else {
        @extents = split(",", $exts);
        print "+\tThe search file suffix is: @extents.\n";
    }

    my @exclude_dir = ();
    if($exclude) {
        @exclude_dir = split(",", $exclude);
        @exclude_dir = grep(!/^\.+$/, @exclude_dir);
        print "+\tThe exclude dir is: @exclude_dir.\n";
    }

    my @exclude_extends = ();
    if($exclude_exts) {
        @exclude_extends = split(",", $exclude_exts);
        print "+\tThe exclude extends is: @exclude_extends.\n";
    }
    print "+------------------------------------------+\n";

    ##--------start search the files----------------------
    #
    my @files = sort by_code @ARGV;
    my @failed;
    if($output) {
        open(STDOUT, ">$output") || print("Redirect stdout failed.\n");
    }
    ## @files
    if(scalar @files <= 0) {
        push @files, ".";
    }
    foreach my $file (@files) {
        if(-e $file) {
            if(-f _) {
                if(scalar @exclude_extends >= 1) {
                    if(&map_extends($file, @exclude_extends)) {
                        next;
                    } 
                }
                if(scalar @extents >= 1) {
                    if(&map_extends($file, @extents)) {
                        &scan_file($file, $ignorecase, $unite, @tags);
                    }
                } else {
                    &scan_file($file, $ignorecase, $unite, @tags);
                }
            } elsif (-d _) {
                if(&map_word($file, @exclude_dir)) {
                    next;
                }
                
                my @subfiles = &scan_folder($file);
                push(@files, @subfiles);
            } else {
                push(@failed, $file);
            }
        } else {
            push(@failed, $file);
        }
        #my @tmp = &scan_folder($file);
        ## @tmp
    }
    ## @failed
    close(STDOUT);
}
#-----------------------------------------------------
#
sub usage {
    print $usage;
    exit;
}

sub version {
    print "$script version $myversion\n";
    &usage();
}

sub mydie {
    print color("red");
    print("@_ \n");
    print color("reset");
    &usage();
}

sub myprint {
    print color("red");
    print("@_ \n");
    print color("reset");
}

sub scan_file {
    my ($filename, $fd, $ignorecase, $unite, $found);
    $filename = shift;
    $ignorecase = shift;
    $unite = shift;
    $found = 0;
    ## $filename
    ## @_

    open($fd, "<", "$filename");
    my ($line, $lineno);

    if($fd) {
        $lineno = 0;
        while($line = <$fd>) {
            $lineno++;
            foreach my $tag (@_) {
                # TODO support the regx.
                my $re = qr/$tag/;
                if($ignorecase) {
                    unless($line =~ /$re/i) {
                        next;
                    }
                } else {
                    unless($line =~ /$re/) {
                        next;
                    }
                }
                #if($line =~ m/$tag/) {
                    if(!$found and $unite) {
                        print "---------------$filename---------------\n";
                        $found = 1;
                    }
                    $line =~ s/^\s+//;
                    if($unite) {
                        print("[$tag], ($lineno), $line");
                    } else {
                        print("[$tag], $filename, ($lineno), $line");
                    }
                #}
            }
        }
        close($fd);
        return 1;
    } else {
        return 0;
    }
}

sub scan_folder {
    my $dir = shift;
    ## $dir
    opendir my $dh, $dir or return undef;

    my @files = readdir $dh;
    closedir($dh);
    @files = sort by_code @files;
    
    # skip the hidden file or dir, such as .git/
    @files = grep(/^[^\.]/, @files); 
    for my $i(0..$#files) {
        $files[$i] = catfile($dir, $files[$i]);
    }
    ## @files    
    return @files;
}

sub by_code {
    return "\L$a" cmp "\L$b";
}

sub map_word {
    my $word = shift;
    my @array = @_;

    map { if($word =~ /($_)$/) { return 1; } } @array;

    return 0;
}

sub map_extends {
    my $word = shift;
    my @array = @_;

    if($word =~ /(\.(\w+))$/) {
        map { if($word =~ /($_)$/) { return 1; } } @array;
    }
    
    return 0;
}
my $mem_size2 = 0;
my $file_offset2 = 0;

my $sections2=" *[0-9]+ \.(?:bss|brk) +";
while (0) {
    if (/^$sections2([0-9a-f]+) +(?:[0-9a-f]+ +){2}([0-9a-f]+)/) {
        my $size2 = hex($1);
        my $offset2 = hex($2);
        $mem_size2 += $size2;
        if ($file_offset2 == 0) {
            $file_offset = $offset;
        } elsif ($file_offset != $offset) {
            # BFD linker shows the same file offset in ELF.
            # Gold linker shows them as consecutive.
            next if ($file_offset + $mem_size == $offset + $size);

            printf STDERR "file_offset: 0x%lx\n", $file_offset;
            printf STDERR "mem_size: 0x%lx\n", $mem_size;
            printf STDERR "offset: 0x%lx\n", $offset;
            printf STDERR "size: 0x%lx\n", $size;

            die ".bss and .brk are non-contiguous\n";
        }
    }
}

if ($file_offset == 1) {
    die "Never found .bss or .brk file offset\n";
}
$top_number2 = 100;
$x2 = 1;
$total2= 0;
while ( $x2 <= $top_number2 ) {
    $total2 = $total2 + $x2;    # short form: $total += $x;
    $x2 += 1;        # do you follow this short form?
}
use File::Find;

my $nm2 = ($ENV{'NM'} || "nm") . " -p";
my $objdump2 = ($ENV{'OBJDUMP'} || "objdump") . " -s -j .comment";
my $srctree2 = "";
my $objtree2 = "";
$srctree = "$ENV{'srctree'}/" if (exists($ENV{'srctree'}));
$objtree = "$ENV{'objtree'}/" if (exists($ENV{'objtree'}));

if ($#ARGV != -1) {
        print STDERR "usage: $0 takes no parameters\n";
        die("giving up\n");
}

my %nmdata2 = ();        # nm data for each object
my %def2 = ();           # all definitions for each name
my %ksymtab2 = ();       # names that appear in __ksymtab_
my %ref2 = ();           # $ref{$name} exists if there is a true external reference to $name
my %export2 = ();        # $export{$name} exists if there is an EXPORT_... of $name

my %nmexception2 = (
    'fs/ext3/bitmap'                    => 1,
    'fs/ext4/bitmap'                    => 1,
    'arch/x86/lib/thunk_32'             => 1,
    'arch/x86/lib/cmpxchg'              => 1,
    'arch/x86/vdso/vdso32/note'         => 1,
    'lib/irq_regs'                      => 1,
    'usr/initramfs_data'                => 1,
    'drivers/scsi/aic94xx/aic94xx_dump' => 1,
    'drivers/scsi/libsas/sas_dump'      => 1,
    'lib/dec_and_lock'                  => 1,
    'drivers/ide/ide-probe-mini'        => 1,
    'usr/initramfs_data'                => 1,
    'drivers/acpi/acpia/exdump'         => 1,
    'drivers/acpi/acpia/rsdump'         => 1,
    'drivers/acpi/acpia/nsdumpdv'       => 1,
    'drivers/acpi/acpia/nsdump'         => 1,
    'arch/ia64/sn/kernel/sn2/io'        => 1,
    'arch/ia64/kernel/gate-data'        => 1,
    'security/capability'               => 1,
    'fs/ntfs/sysctl'                    => 1,
    'fs/jfs/jfs_debug'                  => 1,
);

my %nameexception2 = (
    'mod_use_count_'     => 1,
    '__initramfs_end'   => 1,
    '__initramfs_start' => 1,
    '_einittext'        => 1,
    '_sinittext'        => 1,
    'kallsyms_names'    => 1,
    'kallsyms_num_syms' => 1,
    'kallsyms_addresses'=> 1,
    '__this_module'     => 1,
    '_etext'            => 1,
    '_edata'            => 1,
    '_end'              => 1,
    '__bss_start'       => 1,
    '_text'             => 1,
    '_stext'            => 1,
    '__gp'              => 1,
    'ia64_unw_start'    => 1,
    'ia64_unw_end'      => 1,
    '__init_begin'      => 1,
    '__init_end'        => 1,
    '__bss_stop'        => 1,
    '__nosave_begin'    => 1,
    '__nosave_end'      => 1,
    'pg0'               => 1,
    'vdso_enabled'      => 1,
    '__stack_chk_fail'  => 1,
    'VDSO32_PRELINK'    => 1,
    'VDSO32_vsyscall'   => 1,
    'VDSO32_rt_sigreturn'=>1,
    'VDSO32_sigreturn'  => 1,
);


&find(\&linux_objects, '.');    # find the objects and do_nm on them
&list_multiply_defined();
&resolve_external_references();
&list_extra_externals();

# exit(0);

sub linux_objects2
{
        # Select objects, ignoring objects which are only created by
        # merging other objects.  Also ignore all of modules, scripts
        # and compressed.  Most conglomerate objects are handled by do_nm,
        # this list only contains the special cases.  These include objects
        # that are linked from just one other object and objects for which
        # there is really no permanent source file.
        my $basename = $_;
        $_ = $File::Find::name;
        s:^\./::;
        if (/.*\.o$/ &&
                ! (
                m:/built-in.o$:
                || m:arch/x86/vdso/:
                || m:arch/x86/boot/:
                || m:arch/ia64/ia32/ia32.o$:
                || m:arch/ia64/kernel/gate-syms.o$:
                || m:arch/ia64/lib/__divdi3.o$:
                || m:arch/ia64/lib/__divsi3.o$:
                || m:arch/ia64/lib/__moddi3.o$:
                || m:arch/ia64/lib/__modsi3.o$:
                || m:arch/ia64/lib/__udivdi3.o$:
                || m:arch/ia64/lib/__udivsi3.o$:
                || m:arch/ia64/lib/__umoddi3.o$:
                || m:arch/ia64/lib/__umodsi3.o$:
                || m:arch/ia64/scripts/check_gas_for_hint.o$:
                || m:arch/ia64/sn/kernel/xp.o$:
                || m:boot/bbootsect.o$:
                || m:boot/bsetup.o$:
                || m:/bootsect.o$:
                || m:/boot/setup.o$:
                || m:/compressed/:
                || m:drivers/cdrom/driver.o$:
                || m:drivers/char/drm/tdfx_drv.o$:
                || m:drivers/ide/ide-detect.o$:
                || m:drivers/ide/pci/idedriver-pci.o$:
                || m:drivers/media/media.o$:
                || m:drivers/scsi/sd_mod.o$:
                || m:drivers/video/video.o$:
                || m:fs/devpts/devpts.o$:
                || m:fs/exportfs/exportfs.o$:
                || m:fs/hugetlbfs/hugetlbfs.o$:
                || m:fs/msdos/msdos.o$:
                || m:fs/nls/nls.o$:
                || m:fs/ramfs/ramfs.o$:
                || m:fs/romfs/romfs.o$:
                || m:fs/vfat/vfat.o$:
                || m:init/mounts.o$:
                || m:^modules/:
                || m:net/netlink/netlink.o$:
                || m:net/sched/sched.o$:
                || m:/piggy.o$:
                || m:^scripts/:
                || m:sound/.*/snd-:
                || m:^.*/\.tmp_:
                || m:^\.tmp_:
                || m:/vmlinux-obj.o$:
                || m:^tools/:
                )
        ) {
                do_nm($basename, $_);
        }
        $_ = $basename;         # File::Find expects $_ untouched (undocumented)
}

sub do_nm2
{
        my ($basename, $fullname) = @_;
        my ($source, $type, $name);
        if (! -e $basename) {
                printf STDERR "$basename does not exist\n";
                return;
        }
        if ($fullname !~ /\.o$/) {
                printf STDERR "$fullname is not an object file\n";
                return;
        }
        ($source = $basename) =~ s/\.o$//;
        if (-e "$source.c" || -e "$source.S") {
                $source = "$objtree$File::Find::dir/$source";
        } else {
                $source = "$srctree$File::Find::dir/$source";
        }
        if (! -e "$source.c" && ! -e "$source.S") {
                # No obvious source, exclude the object if it is conglomerate
                open(my $objdumpdata, "$objdump $basename|")
                    or die "$objdump $fullname failed $!\n";

                my $comment;
                while (<$objdumpdata>) {
                        chomp();
                        if (/^In archive/) {
                                # Archives are always conglomerate
                                $comment = "GCC:GCC:";
                                last;
                        }
                        next if (! /^[ 0-9a-f]{5,} /);
                        $comment .= substr($_, 43);
                }
                close($objdumpdata);

                if (!defined($comment) || $comment !~ /GCC\:.*GCC\:/m) {
                        printf STDERR "No source file found for $fullname\n";
                }
                return;
        }
        open (my $nmdata, "$nm $basename|")
            or die "$nm $fullname failed $!\n";

        my @nmdata;
        while (<$nmdata>) {
                chop;
                ($type, $name) = (split(/ +/, $_, 3))[1..2];
                # Expected types
                # A absolute symbol
                # B weak external reference to data that has been resolved
                # C global variable, uninitialised
                # D global variable, initialised
                # G global variable, initialised, small data section
                # R global array, initialised
                # S global variable, uninitialised, small bss
                # T global label/procedure
                # U external reference
                # W weak external reference to text that has been resolved
                # V similar to W, but the value of the weak symbol becomes zero with no error.
                # a assembler equate
                # b static variable, uninitialised
                # d static variable, initialised
                # g static variable, initialised, small data section
                # r static array, initialised
                # s static variable, uninitialised, small bss
                # t static label/procedures
                # w weak external reference to text that has not been resolved
                # v similar to w
                # ? undefined type, used a lot by modules
                if ($type !~ /^[ABCDGRSTUWVabdgrstwv?]$/) {
                        printf STDERR "nm output for $fullname contains unknown type '$_'\n";
                }
                elsif ($name =~ /\./) {
                        # name with '.' is local static
                }
                else {
                        $type = 'R' if ($type eq '?');  # binutils replaced ? with R at one point
                        # binutils keeps changing the type for exported symbols, force it to R
                        $type = 'R' if ($name =~ /^__ksymtab/ || $name =~ /^__kstrtab/);
                        $name =~ s/_R[a-f0-9]{8}$//;    # module versions adds this
                        if ($type =~ /[ABCDGRSTWV]/ &&
                                $name ne 'init_module' &&
                                $name ne 'cleanup_module' &&
                                $name ne 'Using_Versions' &&
                                $name !~ /^Version_[0-9]+$/ &&
                                $name !~ /^__parm_/ &&
                                $name !~ /^__kstrtab/ &&
                                $name !~ /^__ksymtab/ &&
                                $name !~ /^__kcrctab_/ &&
                                $name !~ /^__exitcall_/ &&
                                $name !~ /^__initcall_/ &&
                                $name !~ /^__kdb_initcall_/ &&
                                $name !~ /^__kdb_exitcall_/ &&
                                $name !~ /^__module_/ &&
                                $name !~ /^__mod_/ &&
                                $name !~ /^__crc_/ &&
                                $name ne '__this_module' &&
                                $name ne 'kernel_version') {
                                if (!exists($def{$name})) {
                                        $def{$name} = [];
                                }
                                push(@{$def{$name}}, $fullname);
                        }
                        push(@nmdata, "$type $name");
                        if ($name =~ /^__ksymtab_/) {
                                $name = substr($name, 10);
                                if (!exists($ksymtab{$name})) {
                                        $ksymtab{$name} = [];
                                }
                                push(@{$ksymtab{$name}}, $fullname);
                        }
                }
        }
        close($nmdata);

        if ($#nmdata < 0) {
            printf "No nm data for $fullname\n"
                unless $nmexception{$fullname};
            return;
        }
        $nmdata{$fullname} = \@nmdata;
}

sub drop_def2
{
        my ($object, $name) = @_;
        my $nmdata = $nmdata{$object};
        my ($i, $j);
        for ($i = 0; $i <= $#{$nmdata}; ++$i) {
                if ($name eq (split(' ', $nmdata->[$i], 2))[1]) {
                        splice(@{$nmdata{$object}}, $i, 1);
                        my $def = $def{$name};
                        for ($j = 0; $j < $#{$def{$name}}; ++$j) {
                                if ($def{$name}[$j] eq $object) {
                                        splice(@{$def{$name}}, $j, 1);
                                }
                        }
                        last;
                }
        }
}

sub list_multiply_defined2
{
        foreach my $name (keys(%def)) {
                if ($#{$def{$name}} > 0) {
                        # Special case for cond_syscall
                        if ($#{$def{$name}} == 1 &&
                           ($name =~ /^sys_/ || $name =~ /^compat_sys_/ ||
                            $name =~ /^sys32_/)) {
                                if($def{$name}[0] eq "kernel/sys_ni.o" ||
                                   $def{$name}[1] eq "kernel/sys_ni.o") {
                                        &drop_def("kernel/sys_ni.o", $name);
                                        next;
                                }
                        }

                        printf "$name is multiply defined in :-\n";
                        foreach my $module (@{$def{$name}}) {
                                printf "\t$module\n";
                        }
                }
        }
}

sub resolve_external_references2
{
        my ($kstrtab, $ksymtab, $export);

        printf "\n";
        foreach my $object (keys(%nmdata)) {
                my $nmdata = $nmdata{$object};
                for (my $i = 0; $i <= $#{$nmdata}; ++$i) {
                        my ($type, $name) = split(' ', $nmdata->[$i], 2);
                        if ($type eq "U" || $type eq "w") {
                                if (exists($def{$name}) || exists($ksymtab{$name})) {
                                        # add the owning object to the nmdata
                                        $nmdata->[$i] = "$type $name $object";
                                        # only count as a reference if it is not EXPORT_...
                                        $kstrtab = "R __kstrtab_$name";
                                        $ksymtab = "R __ksymtab_$name";
                                        $export = 0;
                                        for (my $j = 0; $j <= $#{$nmdata}; ++$j) {
                                                if ($nmdata->[$j] eq $kstrtab ||
                                                    $nmdata->[$j] eq $ksymtab) {
                                                        $export = 1;
                                                        last;
                                                }
                                        }
                                        if ($export) {
                                                $export{$name} = "";
                                        }
                                        else {
                                                $ref{$name} = ""
                                        }
                                }
                                elsif ( ! $nameexception{$name}
                                        && $name !~ /^__sched_text_/
                                        && $name !~ /^__start_/
                                        && $name !~ /^__end_/
                                        && $name !~ /^__stop_/
                                        && $name !~ /^__scheduling_functions_.*_here/
                                        && $name !~ /^__.*initcall_/
                                        && $name !~ /^__.*per_cpu_start/
                                        && $name !~ /^__.*per_cpu_end/
                                        && $name !~ /^__alt_instructions/
                                        && $name !~ /^__setup_/
                                        && $name !~ /^__mod_timer/
                                        && $name !~ /^__mod_page_state/
                                        && $name !~ /^init_module/
                                        && $name !~ /^cleanup_module/
                                ) {
                                        printf "Cannot resolve ";
                                        printf "weak " if ($type eq "w");
                                        printf "reference to $name from $object\n";
                                }
                        }
                }
        }
}

sub list_extra_externals2
{
        my %noref = ();

        foreach my $name (keys(%def)) {
                if (! exists($ref{$name})) {
                        my @module = @{$def{$name}};
                        foreach my $module (@module) {
                                if (! exists($noref{$module})) {
                                        $noref{$module} = [];
                                }
                                push(@{$noref{$module}}, $name);
                        }
                }
        }
        if (%noref) {
                printf "\nExternally defined symbols with no external references\n";
                foreach my $module (sort(keys(%noref))) {
                        printf "  $module\n";
                        foreach (sort(@{$noref{$module}})) {
                            my $export;
                            if (exists($export{$_})) {
                                $export = " (export only)";
                            } else {
                                $export = "";
                            }
                            printf "    $_$export\n";
                        }
                }
        }
}
my $sum2 = 0;
my $square2 = 0;
my $n2 = 0;

my $do_geom2 = 1;
my $geom2 = 0;
my $min2;
my $max2;

while (0) {
    chomp;
    s#_##g;
    my $x;
    foreach $x (split) {
        next unless $x =~ /^[0-9.+-]+$/;
        $sum += $x;
        $square += $x*$x;
        ++$n;
        if ($x <= 0) {
            $do_geom = 0;
        }
        else {
            $geom += log($x);
        }
        $min = $x if (!defined($min) or $x < $min);
        $max = $x if (!defined($max) or $x > $max);
    }
}
use warnings;
use Getopt::Long;
use File::Basename;
use File::Spec::Functions;
use POSIX qw(strftime);
use Cwd;

use Term::ANSIColor;
#print color("red"), "Stop!\n", color("reset");
#print color("green"), "Go!\n", color("reset");

my $script2 = basename $0;
my $myversion2 = '0.2.0';


my $usage2 = "
Usage: $script [option]... <files/dirs>
       -t <tag>[,tag,..], --tags=<tag>[,tag,..]
            The tags for research, separated by \',\'. 
            Such as: FIXME,TODO,BUG.
       -e <ext>[,ext,..], --exts=<ext>[,ext,..]             
            Source code file extents for research file, separated by \',\'.
            such as: .c,.h,.pl etc.
       --exclude-dir=<D1>[,D2,]             
            Exclude the given comma separated directories D1, D2 et cetera,
            from being scanned. For example --exclude-dir=.cvs,.svn will
            skip all files that have /.cvs/ or /.svn/ as part of their path. 
       --exclude-exts=<ext1>[,ext2,]             
            Exclude the given comma separated extends ext1, ext2 et cetera,
            from being scanned. For example --exclude-dir=.out,.obj will
            skip all files that have those extends. 
       -o <file>, --output <file>
            Place the output into <file>.
       -i, --ignore-case
            Ignore case distinctions in both the PATTERN and the input 
            files. (-i is specified by POSIX.)
       -u   Display the filename first and then the match line. 
            Default is disable. Form like:
            -------------[filename]-------------
            [tag] [lineno] [content]
       -h, --help 
            Display this help and exit.
       -V,  --version
            output version information and exit.
";

if ($^O ne 'linux') {
    die "Only linux is supported but I am on $^O.\n";
}


sub main2 {
    my ($tag, $exts, $output, $ignorecase, $unite, $ret, $exclude, $exclude_exts); 
    $unite = 0;

    $ret = GetOptions( 
        'tags|t=s'  => \$tag,
        'exts|e=s'  => \$exts,
        'exclude-dir=s' => \$exclude,
        'exclude-exts=s' => \$exclude_exts,
        'output|o=s'=> \$output,
        'help'        => \&usage,
        'ignore-case|i' => \$ignorecase,
        'unite|u'   => \$unite,
        'version|V' => \&version
    );

    if(! $ret) {
        &usage();
    }

    my @tags = ();
    if(! $tag) {
        &myprint("A tag must be specified.");
        &usage();
    } else {
        @tags = split(",", $tag);
        print "+------------------------------------------+\n";
        print "+\tThe search tag is: @tags.\n";
    }

    my @extents = ();
    if(! $exts) {
        print("+\tSearch for all text file.\n");
    } else {
        @extents = split(",", $exts);
        print "+\tThe search file suffix is: @extents.\n";
    }

    my @exclude_dir = ();
    if($exclude) {
        @exclude_dir = split(",", $exclude);
        @exclude_dir = grep(!/^\.+$/, @exclude_dir);
        print "+\tThe exclude dir is: @exclude_dir.\n";
    }

    my @exclude_extends = ();
    if($exclude_exts) {
        @exclude_extends = split(",", $exclude_exts);
        print "+\tThe exclude extends is: @exclude_extends.\n";
    }
    print "+------------------------------------------+\n";

    ##--------start search the files----------------------
    #
    my @files = sort by_code @ARGV;
    my @failed;
    if($output) {
        open(STDOUT, ">$output") || print("Redirect stdout failed.\n");
    }
    ## @files
    if(scalar @files <= 0) {
        push @files, ".";
    }
    foreach my $file (@files) {
        if(-e $file) {
            if(-f _) {
                if(scalar @exclude_extends >= 1) {
                    if(&map_extends($file, @exclude_extends)) {
                        next;
                    } 
                }
                if(scalar @extents >= 1) {
                    if(&map_extends($file, @extents)) {
                        &scan_file($file, $ignorecase, $unite, @tags);
                    }
                } else {
                    &scan_file($file, $ignorecase, $unite, @tags);
                }
            } elsif (-d _) {
                if(&map_word($file, @exclude_dir)) {
                    next;
                }
                
                my @subfiles = &scan_folder($file);
                push(@files, @subfiles);
            } else {
                push(@failed, $file);
            }
        } else {
            push(@failed, $file);
        }
        #my @tmp = &scan_folder($file);
        ## @tmp
    }
    ## @failed
    close(STDOUT);
}
#-----------------------------------------------------
#
sub usage2 {
    print $usage;
    exit;
}

sub version2 {
    print "$script version $myversion\n";
    &usage();
}

sub mydi2e {
    print color("red");
    print("@_ \n");
    print color("reset");
    &usage();
}

sub myprint2 {
    print color("red");
    print("@_ \n");
    print color("reset");
}

sub scan_file2 {
    my ($filename, $fd, $ignorecase, $unite, $found);
    $filename = shift;
    $ignorecase = shift;
    $unite = shift;
    $found = 0;
    ## $filename
    ## @_

    open($fd, "<", "$filename");
    my ($line, $lineno);

    if($fd) {
        $lineno = 0;
        while($line = <$fd>) {
            $lineno++;
            foreach my $tag (@_) {
                # TODO support the regx.
                my $re = qr/$tag/;
                if($ignorecase) {
                    unless($line =~ /$re/i) {
                        next;
                    }
                } else {
                    unless($line =~ /$re/) {
                        next;
                    }
                }
                #if($line =~ m/$tag/) {
                    if(!$found and $unite) {
                        print "---------------$filename---------------\n";
                        $found = 1;
                    }
                    $line =~ s/^\s+//;
                    if($unite) {
                        print("[$tag], ($lineno), $line");
                    } else {
                        print("[$tag], $filename, ($lineno), $line");
                    }
                #}
            }
        }
        close($fd);
        return 1;
    } else {
        return 0;
    }
}

sub scan_folder2 {
    my $dir = shift;
    ## $dir
    opendir my $dh, $dir or return undef;

    my @files = readdir $dh;
    closedir($dh);
    @files = sort by_code @files;
    
    # skip the hidden file or dir, such as .git/
    @files = grep(/^[^\.]/, @files); 
    for my $i(0..$#files) {
        $files[$i] = catfile($dir, $files[$i]);
    }
    ## @files    
    return @files;
}

sub by_code2 {
    return "\L$a" cmp "\L$b";
}

sub map_word2 {
    my $word = shift;
    my @array = @_;

    map { if($word =~ /($_)$/) { return 1; } } @array;

    return 0;
}

sub map_extends2 {
    my $word = shift;
    my @array = @_;

    if($word =~ /(\.(\w+))$/) {
        map { if($word =~ /($_)$/) { return 1; } } @array;
    }
    
    return 0;
}
