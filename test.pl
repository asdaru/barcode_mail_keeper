#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use threads;
use threads::shared;

use File::Basename 'dirname';
use File::Spec;
use Image::Magick;
use Barcode::ZBar;
use Data::Dumper;

# мониторинг осуществляется демоном incron (запись в  incrontab <целевая папка> IN_CREATE /home/asda/workspace/Home/script/arhiv/ImageMonitor.pl $@ $@/$#)


my $conffile = join "/", File::Spec->splitdir( dirname(__FILE__) ), 'scan.conf';
our $conf = do "$conffile";
our $resolution = $conf->{resolution} || 200;

#my $logfile=join "/",File::Spec->splitdir(dirname(__FILE__)),'scan.log';
#open (STDOUT, ">> $logfile") or die "do not forward STDOUT to $logfile...\n";
#open (STDERR, ">> $logfile") or die "do not forward STDERR to $logfile....\n";
{
	my @files = glob("tmp/*.pdf");

	foreach my $file (@files) {

		my $magick = Image::Magick->new( depth => 8, density => $resolution,type => "Grayscale" );

		my $listov = LoadPic( $magick, $file );    #кол-во листов исходя из кол-ва файлов

		my $barcode    = "-";
		my @BarThreads = ();
		my @BarRezult  = ();
#		$magick->Set(monochrome=>1);
#		for ( my $i = 0 ; $magick->[$i] ; $i++ ) {
#			$magick->[$i]->Set(monochrome=>1);
#		}

		#$magick->Morphology(method=>'thicken',kernel=>'1x3:1,0,1');
		#$magick->ReduceNoise(2);
#		$magick->Rotate(-0.9);
#		for ( my $i = 0 ; $magick->[$i] ; $i++ ) {
#			$magick->[$i]->Set(monochrome=>1);
#		}
		#$magick->Morphology(method=>'close',kernel=>'rectangle:1x1');
#		$magick->ReduceNoise(1);

		my @Size       = $magick->Get(qw(columns rows));
		my $i;
		for ( $i = 0 ; $magick->[$i] ; $i++ ) {
			#my $stream = Image::Magick->new( depth => 8, density => $resolution );
			#push @$stream, $magick->[$i];
			#$stream->Morphology(method=>'close',kernel=>'rectangle:3x4');

			my $raw = $magick->[$i]->ImageToBlob( magick => 'GRAY', depth => 8 );
			$BarRezult[$i] = FindBarcode($raw, @Size );
			#undef $stream;
		}
#		for ( my $ii = 0 ; $ii < $i ; $ii++ ) {
#			$BarRezult[$ii] = $BarThreads[$ii]->join;
#		}

		my $SaveId = 0;
		for ( my $ii = 0 ; $ii < $i ; $ii++ ) {
			$barcode .= $BarRezult[$ii] . "-";
		}

		#$magick->Write( filename =>  'tmp/document.pdf', compression => 'JPEG', quality => '80' );

		$barcode =~ s/--/-/g;
		$barcode =~ s/^-//g;
		$barcode =~ s/-$//g;
		warn $file.":   ".$barcode;
		my $f=$file;
		$f=~s/\.pdf$//i;
		# $magick->Write( filename => "$f.jpg", compression => 'JPEG', quality => '80' );
	}
}

exit 1;

#Сохраняет кусоук потока если нашли следующую накладную
#Поток
#Номер последней ячейки
sub SavePartStream {
	my ( $magick, $lastId, $SavePath, $SaveId, $barcode ) = @_;
	$barcode =~ s/--/-/g;
	my $stream = Image::Magick->new( depth => 8, density => $resolution );
	for ( my $ii = 0 ; $ii <= $lastId ; $ii++ ) {
		push @$stream, $magick->[$ii] if $magick->[$ii];
	}
	$stream->Write( filename => "$SavePath/document" . $SaveId . ".jpg", compression => 'JPEG', quality => '80' );
}

#Сохраняем в файл
#Путь,Что сохраняем
sub SaveInfoInFile {
	{
		my $SavePath = shift;
		my $data     = shift;
		my $SaveId   = shift || "";
		my $fh;
		open $fh, '>:utf8', $SavePath . "/currentinfo$SaveId.txt" or warn "Save current error", last;
		print $fh $data;
		close($fh);
	}
}

sub FindBarcode {
	my ( $Raw, $width, $hight ) = @_;

	# wrap image data
	my $image = Barcode::ZBar::Image->new();

	$image->set_format('Y800');
	$image->set_size( $width, $hight );
	$image->set_data($Raw);

	my $scanner = Barcode::ZBar::ImageScanner->new();

	# Включаем все возможные декодеры (по умолчанию EAN13)
	$scanner->parse_config( $conf->{typeEANcodes} || "enable" );    #Apply a decoder configuration setting. See the documentation for zbarcam/zbarimg for available configuration options.
	                                                                # scan the image for barcodes
	my $n       = $scanner->scan_image($image);
	my $barcode = "";

	# extract results
	foreach my $symbol ( $image->get_symbols() ) {
		$barcode .= $symbol->get_data() . "-";

		#print( 'decoded ' . $symbol->get_type() . ' symbol "' . $barcode . "\"\n" );# do something useful with results
	}

	# clean up
	undef($image);
	return $barcode;
}

sub LoadPic {
	my ( $magick, $file ) = @_;
	$conf->{mincolors} = 16000 unless $conf->{mincolors};
	my $calk_listov = 0;
	$magick->Read($file) && die;
	return scalar(@{$magick})
}
