/*
 * Macro template to process multiple images in a folder
 */

#@ File (label = "Input directory", style = "directory") input
#@ File (label = "Output directory", style = "directory") output 
#@ boolean inclsubf (label = "Include subfolders?", default = 1) // including subfolders
#@ boolean overwrite (label = "Overwrite existing?", default = 0) // overwrite existing files with same names
#@ String (label = "File suffix", value = ".czi") suffix // file suffix
#@ String (label = "Inclusion filter", value = "_img.") incfilt // include files with str in name
#@ String (label = "Exclusion filter", value = "bf.") exclfilt // exclude files with str in name

// enable to avoid windows being visusal
setBatchMode(true);
createOutfolders();
processFolder(input);

function createOutfolders() { 
// creates required subfolders in output
	output_tif = output + File.separator + "TIF_out";
	output_png = output + File.separator + "PNG_out";
	if(!File.isDirectory(output_tif)){
		File.makeDirectory(output_tif);
	}
	if(!File.isDirectory(output_png)){
		File.makeDirectory(output_png);
	}
}

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			if(inclsubf){
			processFolder(input + File.separator + list[i]);
			}
		if(endsWith(list[i], suffix)){
			if (matches(list[i], ".*"+incfilt+".*")) {
				if (lengthOf(exclfilt) < 1) {
					print(lengthOf(exclfilt));
						processFile(input, output, list[i]);
					} 
				else {
					print(matches(list[i], ".*"+exclfilt+".*"));
					if (!matches(list[i], ".*"+exclfilt+".*")) {
						processFile(input, output, list[i]);
					} 
				}
			}
		}
	}
}

function processFile(input, output, file) {
	print("Processing: " + input + File.separator + file);
	output_tif = output + File.separator + "TIF_out";
	output_png = output + File.separator + "PNG_out";
	newTitle = file + "_max.tif";
	fl = output_tif + File.separator + newTitle;
	print(fl);
	if(!File.exists(fl) || overwrite){
		path = input+ File.separator +file;
		// import command below might need adaptation with new Bio-Formats updates
		run("Bio-Formats Importer", "open=" + path +" color_mode=Composite rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");	
		run("Z Project...", "projection=[Max Intensity]");
		getDimensions(w, h, channels, slices, frames);
		if (channels > 1) {
			run("Make Composite");
			for (i = 0; i <= channels; i++) {
				Stack.setChannel(i);
				resetMinAndMax();
				if (i == 3) {
					run("Cyan");
				}
				if (i == 4) {
					run("Yellow");
				}
			}
		}
		saveAs("Tiff", output_tif + File.separator + newTitle);
		newTitle = file + "_max.png";
		if (channels > 1) {
		run("Stack to RGB");
		}
		saveAs("png", output_png + File.separator + newTitle);
		run("Close All");
		run("Collect Garbage");
		}
	
}
