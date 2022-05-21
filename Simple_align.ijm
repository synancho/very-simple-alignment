//Simple alignment between channels by moving the first channel by certain number of pixels in xy
//The macro assumes that there are two channels
//Created on 2022-05-20, last updated on 2022-05-20
//Contact SoYeon Kim for questions: soyeon.kim@ucsf.edu

//Show all the images opens up
setBatchMode("show"); 

//Assign the input file type and output file type
inFileType = ".nd2";
outFileType = ".ome.tif";

//The number of pixels to move
moveX = -5;
moveY = 8.25;

//Comanand for enabling Bio-Formats functions
run("Bio-Formats Macro Extensions");

//Choose folders for input and output images
inMainDir=getDirectory("Select source directory with input images");								
outDir=getDirectory("Select or create destination directory for output images and data");

//Listing the subfolders within the main source folder
fileListMain=getFileList(inMainDir); //Listing the files within the main input folder

for (i=0; i<fileListMain.length; i++) { //Looping through all the subfolders and files within the main input folder 	
	
	
	if (endsWith(fileListMain[i],inFileType)) {	//Check the file type
			print(inMainDir);
			alignImg(fileListMain[i], inMainDir);
		}
		
	else {
		print(fileListMain[i]);
		inSubDir = inMainDir+fileListMain[i];
		fileListSub=getFileList(inSubDir); //Listing the files within the subfolder
	
		for (j=0; j<fileListSub.length; j++) { 	//Looping through all the files
		
			if (endsWith(fileListSub[j],inFileType)) {	//Check the file type is .ome.tif		
				alignImg(fileListSub[j], inSubDir);
			}	
		}
	}
}


waitForUser("Process is now complete!");

function alignImg(file, inDir){
	filePath = inDir + file;  //Filepath for the input	
	run("Bio-Formats Importer", "open=[" + filePath + "] color_mode=Default rois_import=[ROI manager] split_channels view=Hyperstack stack_order=XYCZT"); //Import the file
	selectWindow(file + " - C=0");
	run("Translate...", "x=" + moveX + " y=" + moveY + " interpolation=None");
	waitForUser("test");
	run("Merge Channels...", "c1=[" + file + " - C=0] c2=[" + file + " - C=1] create");
	run("Enhance Contrast", "saturated=0.35");

	nameNoExt = replace(file,inFileType,"");  //Generate the name without the extension
	outFile = outDir + nameNoExt + outFileType; 	//Filepath for the ouput 			
	run("Bio-Formats Exporter", "save=[" + outFile + "] compression=Uncompressed"); 	//Exporting using bioformats
	print(file);  //Print the input file location
	run("Close All"); //Closing two image files
}
