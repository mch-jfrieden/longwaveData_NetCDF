function create_longwave_structure(fn_netCDF, VarNames, TimeMin, TimeMax)
    %% in this function we create a general structure for longwave analysis data
    %
    % FRAMEWORK OVERVIEW
    %
    % TemplateCatalogue
    %     -> selects variables
    %
    % VariableCatalogue
    %     -> defines metadata and source variable names
    %
    % DimensionCatalogue
    %     -> defines dimensions and lengths
    %
    % create_longwave_structure
    %     -> assembles the dataset description
    %
    % ncSavVarFil
    %     -> writes the NetCDF file
    %
    %
    %
    % INPUTS:
    %   - fn_netCDF : must be char with the filename of the netCDF file
    %   - VarNames  : an array of char containing the name of the variables 
    %   - TimeMin   : Start time in number of days since 2000-01-01 00:00
    %   - TimeMax   : End time in number of days since 2000-01-01 00:00
    %
    % Possibilities for VarNames are:
    % Time, Temperature, ProfileSurfaceTemp, TemperatureGradient, ProfileSurfacePres, LwdInst1, 
    % LwdInst2, water_vapor, SwDiffuse, SwDirect, SwGlobal, LibRadtranDLR, ParameterizedDLR, 
    % LwdInst1CorrectedIWV, LwdInst2CorrectedIWV, LwdInst1CorrectedSWDif, LwdInst2CorrectedSWDif, LwdInst1CorrectedIWVSWDif, 
    % LwdInst2CorrectedIWVSWDif, SWDifCorrectionCoefDay, SWDifCorrectionCoefDaySE, SWDifCorrectionCoefAll, 
    % SWDifCorrectionCoefAllSE, IWVCorrectionCoef, IWVCorrectionCoefSE
    %
    % The following templates of variables can be called for example
    % VarNames = {'all'} will load the template vector
    %
    % Possibilities are: 
    % 'all', 'inst1wCoef', 'inst1noCoef', 'inst2wCoef', 'inst2noCoef'
    %
    %
    % Assumption:
    % Variables using dimension "Time" are stored in the source
    % dataset with the same temporal sampling as the time vector.
    %
    % Assumption:
    % Variables on dimension "Coef" are static regression
    % coefficients and must not be temporally subsetted.
    %
    %
    %
    % Time variable is expressed in number of days since 2000-01-01 00:00
    % TimeMin in dataset = 4295.0
    % TimeMax in dataset = 9554.5
    %
    % For example: 
    % create_longwave_structure('nameFile.nc', {'Time' 'Temperature'})
    %
    % will create a netcdf file containing those 2 variables, including
    % their attributes and the global general metadata for the entire
    % available time period
    %
    %
    % create_longwave_structure('nameFile.nc', {'all'})
    %
    % will create a netcdf file containing all the variables defined in the
    % variable catalogue with their associated attributes and general global
    % metadata for the entire available time period
    %
    arguments
        fn_netCDF {mustBeTextScalar}
        VarNames cell {mustBeNonzeroLengthText, mustBeText}
        TimeMin {mustBeNumeric} = 4000.
        TimeMax {mustBeNumeric} = 10000.
    end


    %% General global attributes for PAY can easily be loaded with the following function
    nc_gen_Attributes = getGlobalMetadata();

    switch VarNames{1}
        case {'inst1wCoef','inst1noCoef'}
            Instrument = 'Instrument 1: Pyrgeometer Eppley PIR';   
        case {'inst2wCoef','inst2noCoef'}
            Instrument = 'Instrument 2: Pyrgeometer Kipp & Zonen CG4';
        otherwise
            Instrument = '';
    end
    
    if ~isempty(Instrument)
        nc_gen_Attributes(13).Name  = 'Instrument';
        nc_gen_Attributes(13).Value = Instrument;
    end


    %% Define the VarNames array if a template was chosen
    TemplateCatalogue = getTemplateCatalogue();

    if isfield(TemplateCatalogue, VarNames{1})
        VarNames = TemplateCatalogue.(VarNames{1});
    end


    %% Set the time information in global attributes
    % Define the path to the file containing the data values
    pathToFile = 'LWd_meas_Data.nc';

    TimeA = ncread(pathToFile, 'time');
    Cond = TimeA < TimeMax & TimeA > TimeMin;
    TimeFiltered = TimeA(Cond);

    refDate = datetime(2000, 1, 1);
    dt = refDate + days(TimeFiltered);
    dt.Format = 'dd-MMM-yyyy hh:mm:ss';
    nc_gen_Attributes(16).Value = char(dt(1));
    nc_gen_Attributes(17).Value = char(dt(end));
    currentDT = datetime('now');
    nc_gen_Attributes(18).Value = char(currentDT);


    %% Load the dimension catalogue
    nVal = length(TimeFiltered);
    DimVec = getDimensions(nVal);

    %% Load the common variable catalogue for longwave analysis
    catVarsVec = getVariableCatalogue();

    %% Build NetCDF variable schema
    nc_VarSchema = struct('Name', {}, 'Datatype', {}, 'Attributes', {}, 'Dimensions', {}, ...
        'Size', {}, 'Val2Save', {});

    % Loop over all variables in VarNames to finalise their definition and
    % include them in the NetCDF structure
    for i = 1:numel(VarNames)
        assert( isfield(catVarsVec,VarNames{i}), 'Variable "%s" not found in catalogue.', VarNames{i});
        VarDims = catVarsVec.(VarNames{i}).Dimensions;
        assert( isfield(DimVec,VarDims), 'Dimension "%s" not found in catalogue.', VarDims);
        dimids = DimVec.(VarDims);
        Var = catVarsVec.(VarNames{i});
        Var.Size = dimids.Length;
        temp = ncread(pathToFile, catVarsVec.(VarNames{i}).SourceName);

        % Time-dependent variables are cropped to the selected temporal
        % interval. Static variables are kept unchanged.
        if DimVec.(VarDims).Unlimited
            Data = temp(Cond);
        else
            Data = temp;
        end
        Var.Val2Save = Data;
        Var.Dimensions = dimids;
        Var = rmfield(Var,'Coordinates');
        Var = rmfield(Var,'SourceName');
        nc_VarSchema(i) = Var;
    end

    %% Write the NetCDF file
    ncSavVarFil( fn_netCDF, nc_VarSchema, 'Attributes', nc_gen_Attributes );

end