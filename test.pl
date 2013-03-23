#!/usr/local/bin/perl
use strict;
use warnings;
use utf8;
use PDF::API2::Lite;
use Data::Section::Simple qw(get_data_section);

# create file list
my $data = get_data_section('test.data');
my $imagefiles = eval $data or die $!;

# initialize pdf
my $pdf = PDF::API2::Lite->new;
$pdf->page(595, 842);

# initialize background (背景を塗りつぶす：透過の確認のため)
$pdf->fillcolor('#aaaadd');
$pdf->rect( 0, 0, 595, 842 );
$pdf->fill;

# init valuables
my $img = undef;
my $y   = 780;

# font objects (summery のテキストを描画するために用意)
my $fontfile = '/usr/share/fonts/japanese/TrueType/VL-Gothic-Regular.ttf';
my $font = $pdf->ttfont($fontfile, -encode=>"utf-8"); 
$pdf->fillcolor('#000000');

# start drawing
foreach my $f (@$imagefiles) {
	# summery のテキストを描画
	$pdf->print($font, 12, 80, $y+12, 0, 0, $f->{summery});
	# ファイルの ext を見て、処理を振り分ける
	$f->{file} =~ /.+\.(jpe?g|png|tiff?|gif)$/;
	my $ext = $1;
	eval {
		if ($ext =~ /jpe?g/i) {				# JPEG
			print $f->{summery} . "\n";
			$img = $pdf->image_jpeg($f->{file});
		} elsif ($ext =~ /png/i){			# PNG
			print $f->{summery} . "\n";
			$img = $pdf->image_png($f->{file});
		} elsif ($ext =~ /tiff?/i){			# TIFF
			print $f->{summery} . "\n";
			$img = $pdf->image_tiff($f->{file});
		} else {
		}
		$pdf->image($img, 40, $y, 1);		# 描画
	};
	if($@) {
		# エラー文字列をテキストで描画
		$pdf->print($font, 12, 300, $y+12, 0, 0, substr($@, 0, 36));
	}
	$y -= 40;
}
$pdf->saveas('test.pdf');

__DATA__
@@ test.data
[
	# png
	{ summery => 'RGB    8bit PNG',  			file => 'images/RGB8.png', },
	{ summery => 'RGB+A  8bit PNG',  			file => 'images/RGBA8.png', },
	{ summery => 'RGB   16bit PNG',  			file => 'images/RGB16.png', },
	{ summery => 'RGB    8bit interlace PNG',  	file => 'images/RGB8interlace.png', },
	{ summery => 'RGB+A  8bit interlace PNG',  file => 'images/RGBA8interlace.png', },

	# jpeg
	{ summery => 'RGB  8bit JPEG',  			file => 'images/RGB8.jpg', },
	{ summery => 'RGB  8bit JPEG (Progressive)',	file => 'images/RGB8progressive.jpg', },
	{ summery => 'CMYK 8bit JPEG',  			file => 'images/CMYK8.jpg', },
	{ summery => 'CMYK 8bit JPEG (Progressive)', 	file => 'images/CMYK8progressive.jpg', },

	# tiff
	{ summery => 'RGB   8bit TIFF (IBM)',  		file => 'images/RGB8ibm.tif', },
	{ summery => 'RGB  16bit TIFF (IBM)',  		file => 'images/RGB16ibm.tiff', },
	{ summery => 'RGB  16bit TIFF (MAC)',  		file => 'images/RGB16mac.tif', },
	{ summery => 'RGB  16bit TIFF (LZW comp)',  	file => 'images/RGB16ibm_lzw.tif', },
	{ summery => 'CMYK  8bit TIFF (IBM)',  		file => 'images/CMYK8ibm.tif', },
	{ summery => 'CMYK 16bit TIFF (IBM)',  		file => 'images/CMYK16ibm.tif', },
	{ summery => 'CMYK 16bit TIFF (MAC)',  		file => 'images/CMYK16mac.tif', },
	{ summery => 'CMYK 16bit TIFF (LZW comp)',  	file => 'images/CMYK16ibm_lzw.tif', },
];



