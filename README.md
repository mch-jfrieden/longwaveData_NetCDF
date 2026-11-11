# longwaveData_NetCDF
Project of creating FAIR longwave datasets by storing them in a NetCDF file

## FRAMEWORK OVERVIEW
- TemplateCatalogue
  -> selects variables
- VariableCatalogue
  -> defines metadata and source variable names
- DimensionCatalogue
  -> defines dimensions and lengths
- create_longwave_structure
  -> assembles the dataset description
- ncSavVarFil
  -> writes the NetCDF file
  
## INPUTS:
  - ```fn_netCDF``` : must be char with the filename of the netCDF file
  - ```VarNames```  : an array of char containing the name of the variables 
  - ```DataValues```: must be char with the filename containing a structure called "DataValuesStruct" that contains data values of the mentioned variables in VarNames
  - ```TimeMin```   : Start time in number of days since 2000-01-01 00:00
  - ```TimeMax```   : End time in number of days since 2000-01-01 00:00

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
  
Time variable is expressed in number of days since 2000-01-01 00:00
  TimeMin in dataset = 4295.0
  TimeMax in dataset = 9554.5
  
## Example: 

```create_longwave_structure('nameFile.nc', {'Time' 'Temperature'}, 'longwaveDataStruct.mat')```

will create a netcdf file containing those 2 variables, including their attributes and the global general metadata for the entire available time period

```create_longwave_structure('nameFile.nc', {'all'}, 'longwaveDataStruct.mat')```

will create a netcdf file containing all the variables defined in the variable catalogue with their associated attributes and general global metadata for the entire available time period
