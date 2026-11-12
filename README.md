# longwaveData_NetCDF
MATLAB framework for creating FAIR and self-describing NetCDF datasets for atmospheric downward longwave radiation studies.

The framework combines:  
  - CF-compliant variable metadata
  - WMO OSCAR-inspired variable descriptions
  - standardized templates for different dataset configurations
  - automatic generation of NetCDF files from MATLAB data structures

## FRAMEWORK OVERVIEW
- getTemplateCatalogue.m  
  -> selects variable names  
- getVariableCatalogue.m  
  -> contains the variable description and metadata specific for atmospheric longwave radiation studies  
- getGlobalMetadata.m  
  -> contains the global metadata attributes specific for the atmospheric longwave radiation study at the Payerne station  
- getDimensionCatalogue.m  
  -> defines dimensions and lengths  
- ncSavVarFil.m  
  -> writes the NetCDF file  
- create_longwave_structure.m
  -> assembles the dataset by calling all the scripts and associates the data values to each variable before writing the NetCDF file
  
## INPUT ARGUMENTS FOR create_longwave_structure.m:
  - ```fn_netCDF``` : must be char with the filename of the netCDF file
  - ```VarNames```  : an array of char containing the name of the variables 
  - ```DataValues```: must be char with the filename containing a structure called "DataValuesStruct" that contains data values of the mentioned variables in VarNames
  - ```TimeMin```   : Start time in datetime format  
  - ```TimeMax```   : End time in datetime format  

  
Possibilities for VarNames are:
  ```TimeRaw```, ```LwdInst1Raw```, ```LwdInst2Raw```, ```SwDiffuseRaw```, ```SwDirectRaw```, ```SwGlobalRaw```, ```ClearSkyFlag```, ```Time```, ```Temperature```, ```ProfileSurfaceTemp```, ```TemperatureGradient```, ```ProfileSurfacePres```, ```LwdInst1```, ```LwdInst2```, ```water_vapor```, ```SwDiffuse```, ```SwDirect```, ```SwGlobal```, ```LibRadtranDLR```, ```ParameterizedDLR```, ```LwdInst1CorrectedIWV```, ```LwdInst2CorrectedIWV```, ```LwdInst1CorrectedSWDif```, ```LwdInst2CorrectedSWDif```, ```LwdInst1CorrectedIWVSWDif```, ```LwdInst2CorrectedIWVSWDif```, ```SWDifCorrectionCoefDay```, ```SWDifCorrectionCoefDaySE```, ```SWDifCorrectionCoefAll```, ```SWDifCorrectionCoefAllSE```, ```IWVCorrectionCoef```, ```IWVCorrectionCoefSE```
  
  
The following templates of variables can be called for example
  ```VarNames = {'all'}``` will load the template vector
  
  Possibilities are: 
    ```'all'```, ```allCS```, ```allRAW```, ```'inst1wCoef'```, ```'inst1noCoef'```, ```'inst2wCoef'```, ```'inst2noCoef'```
  
  
Assumption:
  Variables using dimension "Time" are stored in the source dataset with the same temporal sampling as the time vector.
  
Assumption:
  Variables on dimension "Coef" are static regression coefficients and must not be temporally subsetted.
  
  
## Example: 

```create_longwave_structure('nameFile.nc', {'Time' 'Temperature'}, 'longwaveDataStruct.mat')```

will create a netcdf file containing those 2 variables, including their attributes and the global general metadata for the entire available time period

```create_longwave_structure('nameFile.nc', {'all'}, 'longwaveDataStruct.mat')```

will create a netcdf file containing all the variables defined in the variable catalogue with their associated attributes and general global metadata for the entire available time period

### Example output:  
ncdump -h test.nc
