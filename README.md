# NAME

Util::Medley - A collection of commonly used utilities.

# VERSION

version 0.062

# SYNOPSIS

     use Util::Medley;  
     
     my $medley = Util::Medley->new;
    
     my $cache = $medley->Cache;
     my $crypt = $medley->Crypt;
     my $dt    = $medley->DateTime;
     ...
    
     OR you can create the objects directly.  Note: this module loads all
     classes in one shot.
    
     use Util::Medley;
      
     my $cache = Util::Medley::Cache->new;
     my $crypt = Util::Medley::Crypt->new;
     my $dt    = Util::Medley::DateTime->new;  
     ...
      

# DESCRIPTION 

Let's face it, CPAN is huge and finding the right module to use can waste
a lot of time.  Once you find what you want, you may even have to refresh 
your memory on how to use it.  That's where Util::Medley comes in.  It is a 
collection of lightweight modules that provide a standard/consistent 
interface to commonly used modules all under one roof.

- [Util::Medley::Cache](https://metacpan.org/pod/Util%3A%3AMedley%3A%3ACache)
- [Util::Medley::Crypt](https://metacpan.org/pod/Util%3A%3AMedley%3A%3ACrypt)
- [Util::Medley::DateTime](https://metacpan.org/pod/Util%3A%3AMedley%3A%3ADateTime)
- [Util::Medley::File](https://metacpan.org/pod/Util%3A%3AMedley%3A%3AFile)
- [Util::Medley::File::Zip](https://metacpan.org/pod/Util%3A%3AMedley%3A%3AFile%3A%3AZip)
- [Util::Medley::List](https://metacpan.org/pod/Util%3A%3AMedley%3A%3AList)
- [Util::Medley::Logger](https://metacpan.org/pod/Util%3A%3AMedley%3A%3ALogger)
- [Util::Medley::Spawn](https://metacpan.org/pod/Util%3A%3AMedley%3A%3ASpawn)
- [Util::Medley::String](https://metacpan.org/pod/Util%3A%3AMedley%3A%3AString)
- [Util::Medley::XML](https://metacpan.org/pod/Util%3A%3AMedley%3A%3AXML)
