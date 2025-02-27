#' Read fisheries XML data format file
#'
#' Read fisheries XML data format file. Currently supports IMR Biotic version 1 until 3, IMR Echosounder version 1, and IMR Landing version 2 formats at the moment.
#' Streaming XML pull parser can be used to avoid loading the whole XML into memory and it supports ZIP file reading. Please note that
#' the XML file inside the zip file should be using the same name as the zip file itself (e.g. test.xml inside test.zip). 
#'
#' @param xmlFilePath full path to the XML file to be read.
#' @param stream a streaming XML pull parser is used if this is set to TRUE. An XML DOM parser is used if this is set to FALSE. Default to TRUE.
#' @param useXsd Specify an xsd object to use. Default to NULL.
#'
#' @return List of data.table objects containing the "flattened" XML data.
#'
#' @examples
#' \dontrun{
#' # Reading test.xml using XML pull parser
#' one <- readXmlFile("./test.xml")
#' # Reading test.xml using XML DOM parser
#' two <- readXmlFile("./test.xml", stream = FALSE)
#' # Reading test.xml inside test.zip file
#' three <- readXmlFile("./test.zip")
#' }
#'
#' @useDynLib RstoxData
#' @importFrom Rcpp sourceCpp
#' @importFrom data.table as.data.table transpose
#'
#' @export
readXmlFile <- function(xmlFilePath, stream = TRUE, useXsd = NULL) {

	# Ices Acoustic XSD needs several additional treatment
	icesAcousticPreprocess <- function(xsdObject) {

		AC <- xsdObject

		# We only interested in these tables
		allData <- c("Acoustic", "Instrument", "Calibration", "DataAcquisition", "DataProcessing", "Cruise", "Survey", "Log", "Sample", "Data")
		newAC <- lapply(AC, function(x) x[allData])

		# Set again the root
		newAC$root <- "Acoustic"

		# Re-build prefix data
		newAC$prefixLens[allData] <- 0

		allDatawithPrefix <- c("Instrument", "Calibration", "DataAcquisition", "DataProcessing", "Cruise", "Survey", "Log", "Sample", "Data")

		newAC$prefixLens[allDatawithPrefix] <- 1
		newAC$prefixLens["Log"] <- 2
		newAC$prefixLens["Sample"] <- 3
		newAC$prefixLens["Data"] <- 4

		newAC$tableHeaders$Log <- c("LocalID", newAC$tableHeaders$Log)
		newAC$tableHeaders$Sample <- c("LocalID", "Distance", newAC$tableHeaders$Sample)
		newAC$tableHeaders$Data <- c("LocalID", "Distance", "ChannelDepthUpper", newAC$tableHeaders$Data)

		# Modify cruise structure to get LocalID as prefix
		newAC$tableHeaders$Cruise <- c("LocalID", "Country", "Platform", "StartDate", "EndDate", "Organisation")

		return(newAC)
	}

	# Process column names and types
	applyNameType <- function(x, result, tableHeaders, tableTypes) {

		# Get result matrix
		y <- result[[x]]

		# Handle empty data
		if(ncol(y) == 0)
			y <- matrix(data = "", nrow = 0, ncol = length(tableHeaders[[x]]))

		# Convert to data.table
		z <- as.data.table(y)

		# Set column names
		tableHeader <- tableHeaders[[x]]
		Encoding(tableHeader) <- "UTF-8"
		colnames(z) <- tableHeader

		# Set encoding (Rcpp uses UTF-8)
		for (cn in colnames(z)) {
			Encoding(z[[cn]]) <- "UTF-8"
		}

		# Set column types (only double and integer for now)
		tableType <- tableTypes[[x]]
		if(length(tableType) > 0) {
			for(i in 1:ncol(z)) {
				j <- tail(unlist(strsplit(tableType[i], ":")), 1)
				if(j %in% c("double", "integer", "decimal")) {
					# Map the types
					typeMap <- c("double" = "double", "integer" = "integer", "decimal" = "double")
					doConv <- eval(parse(text = paste0("as.", typeMap[[j]])))
					z[, tableHeader[i] := doConv(z[[tableHeader[i]]])]
				}
			}
		}
		return(z)
	}

	# Load data if necessary
	if(!exists("xsdObjects"))
		xsdObjects <- RstoxData::xsdObjects

	# Expand path
	xmlFilePath <- path.expand(xmlFilePath)

	# Check file exists
	if(!file.exists(xmlFilePath)) {
		print(paste("File", xmlFilePath, "does not exist."))
		return(NULL)
	}

	# Try to do autodetect
	found <- autodetectXml(xmlFilePath, xsdObjects)
	if(is.null(useXsd))
		useXsd <- found[["xsd"]]

	# Apply preprocess for ICES XSD
	if(useXsd == "icesAcoustic") {
		xsdObjects$icesAcoustic.xsd <- icesAcousticPreprocess(xsdObjects$icesAcoustic.xsd)
	}

	# Invoke C++ xml reading
	if(stream) {
		res <- readXmlCppStream(xmlFilePath, xsdObjects, useXsd, found[["encoding"]])
	} else {
		res <- readXmlCpp(xmlFilePath, xsdObjects, useXsd, found[["encoding"]])
	}

	result <- res[["result"]]
	xsd <- res[["xsd"]]

	# Fix encoding on the result list names
	xx <- names(result)
	Encoding(xx) <- "UTF-8"
	names(result) <- xx

	tableHeaders <- xsdObjects[[xsd]][["tableHeaders"]]
	tableTypes <- xsdObjects[[xsd]][["tableTypes"]]

	# Finishing touch
	final <- lapply(names(result), applyNameType, result, tableHeaders, tableTypes)
	names(final) <- names(result)

	# Add metadata
	final[["metadata"]] <- list(useXsd = useXsd, file = xmlFilePath)

	return(final)
}
