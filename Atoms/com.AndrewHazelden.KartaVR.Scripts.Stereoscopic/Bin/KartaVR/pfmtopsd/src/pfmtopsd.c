/*
pfmtopsd v1.0 - 2019-10-15
Converts a greyscale Portable Float Map .pfm image into a 16-Bit Photoshop .psd.
by Andrew Hazelden
Email: andrew@andrewhazelden.com
Web: www.andrewhazelden.com

The pfmtopsd program is based upon an original proof of concept code by Paul Bourke.

Web: http://www.paulbourke.net/
Email: paul.bourke@gmail.com

------------------------------------------------------------------------------
To compile for macOS use:

cd "/Library/Application Support/Blackmagic Design/Fusion/Reactor/Deploy/Bin/KartaVR/pfmtopsd/src/"
make -f Makefile.osx

To test the tool use either:

./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" > "$HOME/Desktop/pfm/output.psd"

./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" > "$HOME/Desktop/pfm/output.psd" 2> "$HOME/Desktop/pfm/pfmtopsd.txt"

To pipe the psd format output directly to imagemagick use:

./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- jpg:"$HOME/Desktop/pfm/image.jpg"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- tif:"$HOME/Desktop/pfm/image.tif"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- exr:"$HOME/Desktop/pfm/image.exr"
./pfmtopsd "$HOME/Desktop/pfm/depth16.pfm" | convert psd:- tga:"$HOME/Desktop/pfm/image.tga"

To inspect the EXR output use:
exrheader $HOME/Desktop/pfm/image.exr

------------------------------------------------------------------------------

MIT License

pfmtopsd.c Copyright (c) 2017-2019 Andrew Hazelden

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// For Windows stdout binary mode changing
#ifdef _WIN32
#include <io.h>
#include <fcntl.h>
#endif

#define TRUE	1
#define FALSE 0
#define RGB 0
#define GREY 1
#define BIG 0
#define LITTLE 1
#define MIN(x,y) (x < y ? x : y)
#define MAX(x,y) (x > y ? x : y)

int verbose = TRUE;

int ReadLine(FILE *,char *,int);
int ReadFloat(FILE *,float *,int);
int WriteShort(FILE *,short,int);
int WriteInt(FILE *,int,int);

/*
	Assumes the computer hardware is "Little Endian" aka Intel, so swap the byte order if file is big
	Only supports greyscale and writes result to 16 bit psd file. Adding rgb support is trivial.
 */

int main(int argc,char **argv)
{
	int i,j;
	FILE *fptr, *fpsd;
	char aline[256];
	float aspect, floatvalue, themin = 1e32, themax = -1e32;
	int depth = GREY, endian = BIG;
	long datastart;
	
	// PSD stuff
	char header[8] = "8BPS";
	unsigned short int version = 1, channels = 1, zero = 0;
	unsigned int width = 150, height = 200;
	unsigned int zerolength = 0;
	unsigned short outdepth = 16, colourmode = 1, compression = 0;
	unsigned short shortvalue = 0;
	int modeResult = 0;

	fprintf(stderr, "\npfmtopsd v1.0 2019-10-15\n");
	fprintf(stderr, "Convert a greyscale .pfm image into a 16-Bit Photoshop .psd.\n");
	fprintf(stderr, "---------------------------------------------------------------------\n");
	fprintf(stderr, "Created by Andrew Hazelden <andrew@andrewhazelden.com>\n");
	fprintf(stderr, "Based upon original proof of concept code by Paul Bourke.\n");
	fprintf(stderr, "---------------------------------------------------------------------\n");
	
	// Expect one command line argument
	if (argc < 2){
		//fprintf(stderr, "Usage: %s input.pfm > output.psd 2> stderr.txt\n", argv[0]);
		fprintf(stderr, "Usage: %s input.pfm > output.psd\n", argv[0]);
		exit(-1);
	}

	// Open input pfm file
	// Read as a binary file with "rb" to avoid "r" style newline text character translations on Windows
	if ((fptr = fopen(argv[1],"rb")) == NULL){
		fprintf(stderr, "Failed to open input file \"%s\"\n", argv[1]);
		exit(-1);
	}
	
	// ID
	ReadLine(fptr, aline, 6);
	if (verbose){
		fprintf(stderr, "Header: %c%c\n", aline[0], aline[1]);
	}
	
	if (aline[0] != 'P' && (aline[1] != 'f' || aline[1] != 'F')){
		fprintf(stderr, "This does not look like a pfm image.\n");
		exit(-1);
	}
	
	if (aline[1] == 'F'){
		depth = RGB;
	}
	
	if (depth != GREY){
		fprintf(stderr, "This program only handles greyscale pfm images!\n");
		exit(-1);
	}
	
	// Width and height
	ReadLine(fptr,aline,200);
	sscanf(aline, "%d %d", &width, &height);
	if (verbose){
		fprintf(stderr,"Dimensions: %d x %d\n", width, height);
	}
	
	// Aspect ratio and endian
	ReadLine(fptr, aline, 200);
	sscanf(aline, "%f", &aspect);
	if (verbose){
		fprintf(stderr, "Aspect: %lf (negative infers little endian)\n", aspect);
	}
	
	if (aspect < 0){
		endian = LITTLE;
	}
	
	// Read image data
	datastart = ftell(fptr);
	if (verbose){
		fprintf(stderr, "Data starts from: %ld\n", datastart);
	}
	
	for (j=0;j<height;j++){
		for (i=0;i<width;i++){
			if (!ReadFloat(fptr, &floatvalue, endian == BIG ? TRUE : FALSE)){
				fprintf(stderr, "Reached unexpected end of file at %d,%d\n", i, j);
				break;
			}
			
			themin = MIN(themin, floatvalue);
			themax = MAX(themax, floatvalue);
		}
	}
	
	if (verbose){
		fprintf(stderr, "Pixel range: %g to %g\n", themin, themax);
	}
	
	fseek(fptr, datastart, 0);
	
	
	// Write PSD file
	fprintf(stderr, "Writing the psd image to the standard output.\n");
	//if ((fpsd = fopen(outputFilename,"wb")) == NULL){
	//	fprintf(stderr, "Failed to open output file \"%s\"\n", outputFilename);
	//	exit(-1);
	//}
	
	
	// On Windows the standard output needs to be switched to binary to avoid \n to \r\n translations
	// https://msdn.microsoft.com/en-us/library/tw4k6df8(v=vs.80).aspx
	#ifdef _WIN32
	modeResult = setmode(fileno(stdout), O_BINARY);
	if(modeResult == -1){
		fprintf(stderr, "Cannot set standard output to binary mode.\n");
	}else{
		fprintf(stderr, "Successfully changed standard output to binary mode\n");
	}
	#endif
	
	// Header
	fwrite(header, 4, 1, stdout);
	WriteShort(stdout, version, TRUE);
	
	for (i=0;i<3;i++){
		WriteShort(stdout, zero, TRUE);
	}
	
	WriteShort(stdout, channels, TRUE);
	WriteInt(stdout, height, TRUE);
	WriteInt(stdout, width, TRUE);
	WriteShort(stdout, outdepth, TRUE);
	WriteShort(stdout, colourmode, TRUE);
	WriteInt(stdout, zerolength, TRUE); // Colour mode data
	WriteInt(stdout, zerolength, TRUE); // Image resource data
	WriteInt(stdout, zerolength, TRUE); // Layer and mask section
	
	// Image data
	WriteShort(stdout,compression,TRUE);
	for (j=0;j<height;j++){
		for (i=0;i<width;i++){
			if (!ReadFloat(fptr, &floatvalue, endian == BIG ? TRUE : FALSE)){
				fprintf(stderr, "Reached unexpected end of file at %d,%d\n", i, j);
				break;
			}
			
			shortvalue = log(1 + floatvalue - themin) * 65535 / log(1 + themax - themin);
			WriteShort(stdout, shortvalue, TRUE);
		}
	}
	
	//fclose(stdout);
	fclose(fptr);
	
	
	printf("<Done>\n");
	exit(0);
}

int ReadLine(FILE *fptr, char *s, int lmax){
	int i=0, c;
	
	s[0] = '\0';
	while ((c = fgetc(fptr)) != '\n' && c != '\r'){
		if (c == EOF){
			return(FALSE);
		}
		
		s[i] = c;
		i++;
		s[i] = '\0';
		
		if (i >= lmax){
			break;
		}
		
	}
	return(TRUE);
}

int ReadFloat(FILE *fptr, float *n, int swap){
	unsigned char *cptr, tmp;
	
	if (fread(n, 4, 1, fptr) != 1){
		return(FALSE);
	}
	
	if (swap){
		cptr = (unsigned char *)n;
		tmp = cptr[0];
		cptr[0] = cptr[3];
		cptr[3] = tmp;
		tmp = cptr[1];
		cptr[1] = cptr[2];
		cptr[2] = tmp;
	}
	
	return(TRUE);
}

int WriteInt(FILE *fptr, int n, int swap){
	unsigned char *cptr, tmp;
	
	if (!swap){
		if (fwrite(&n, 4, 1, fptr) != 1){
			return(FALSE);
		}
	}else{
		cptr = (unsigned char *)(&n);
		tmp = cptr[0];
		cptr[0] = cptr[3];
		cptr[3] = tmp;
		tmp = cptr[1];
		cptr[1] = cptr[2];
		cptr[2] = tmp;
		if (fwrite(&n ,4, 1, fptr) != 1){
			return(FALSE);
		}
	}
	
	return(TRUE);
}

int WriteShort(FILE *fptr, short n, int swap){
	unsigned char *cptr, tmp;
	
	if (!swap){
		if (fwrite(&n, 2, 1, fptr) != 1){
			return(FALSE);
		}
	}else{
		cptr = (unsigned char *)(&n);
		tmp = cptr[0];
		cptr[0] = cptr[1];
		cptr[1] = tmp;
		if (fwrite(&n, 2, 1, fptr) != 1){
			return(FALSE);
		}
	}
	
	return(TRUE);
}
