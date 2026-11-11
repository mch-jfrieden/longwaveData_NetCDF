function create_longwave_structure(fn_netCDF, VarNames, DataValues, TimeMin, TimeMax)
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
    %   - DataValues: must be char with the filename containing a structure
    %   called "DataValuesStruct" that contains data values of the mentioned 
    %   variables in varNames
    %   - TimeMin   : Start time in number of days since 2000-01-01 00:00
    %   - TimeMax   : End time in number of days since 2000-01-01 00:00
    %
    % Possibilities for VarNames are:
    % TimeRaw, LwdInst1Raw, LwdInst2Raw, SwDiffuseRaw, SwDirectRaw, SwGlobalRaw, ClearSkyFlag, Time, 
    % Temperature, ProfileSurfaceTemp, TemperatureGradient, ProfileSurfacePres, LwdInst1, 
    % LwdInst2, water_vapor, SwDiffuse, SwDirect, SwGlobal, LibRadtranDLR, ParameterizedDLR, 
    % LwdInst1CorrectedIWV, LwdInst2CorrectedIWV, LwdInst1CorrectedSWDif, LwdInst2CorrectedSWDif, LwdInst1CorrectedIWVSWDif, 
    % LwdInst2CorrectedIWVSWDif, SWDifCorrectionCoefDay, SWDifCorrectionCoefDaySE, SWDifCorrectionCoefAll, 
    % SWDifCorrectionCoefAllSE, IWVCorrectionCoef, IWVCorrectionCoefSE
    %
    % The following templates of variables can be called for example
    % VarNames = {'all'} will load the template vector
    %
    % Possibilities are: 
    % 'all', 'allCS', 'allRAW' 'inst1wCoef', 'inst1noCoef', 'inst2wCoef', 'inst2noCoef'
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
    % create_longwave_structure('nameFile.nc', {'Time' 'Temperature'}, 'longwaveDataStruct.mat')
    %
    % will create a netcdf file containing those 2 variables, including
    % their attributes and the global general metadata for the entire
    % available time period
    %
    %
    % create_longwave_structure('nameFile.nc', {'all'}, 'longwaveDataStruct.mat')
    %
    % will create a netcdf file containing all the variables defined in the
    % variable catalogue with their associated attributes and general global
    % metadata for the entire available time period
    %
    arguments
        fn_netCDF {mustBeTextScalar}
        VarNames cell {mustBeNonzeroLengthText, mustBeText}
        DataValues {mustBeTextScalar}
        TimeMin double {mustBeNumeric} = 4000.
        TimeMax double {mustBeNumeric} = 10000.
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
        AttrNames = {nc_gen_Attributes.Name};
        idx = strcmp(AttrNames,'Instruments');
        nc_gen_Attributes(idx).Name = 'Instrument';
        nc_gen_Attributes(idx).Value = Instrument;
    end


    %% Define the VarNames array if a template was chosen
    TemplateCatalogue = getTemplateCatalogue();

    if isfield(TemplateCatalogue, VarNames{1})
        VarNames = TemplateCatalogue.(VarNames{1});
    end


    %% Set the time information in global attributes
    % Define the path to the file containing the data values
    %pathToFile = 'LWd_meas_Data.nc';

    DataValuesStruct = (load(DataValues));
    DataValuesStruct = DataValuesStruct.DataValuesStruct;
    NameValues = fieldnames(DataValuesStruct);

    nValRaw = 0;
    nVal = 0;
    TimeFiltered = 0.;
    Cond = 0.;
    CondRaw = 0.;
    CondRawHalf = 0;
    if any(strcmp(NameValues, 'time'))
        TimeA = DataValuesStruct.time;
        Cond = TimeA < TimeMax & TimeA > TimeMin;
        nVal = numel(TimeA(Cond));
        TimeFiltered = TimeA(Cond);
    end
    if any(strcmp(NameValues, 'TimeRaw'))
        TimeARaw = DataValuesStruct.TimeRaw;
        CondRaw = TimeARaw < TimeMax & TimeARaw > TimeMin;
        nValRaw = numel(TimeARaw(CondRaw));
        TimeFiltered = TimeARaw(CondRaw);
        integerMask = mod(TimeARaw, 1) == 0;
        temp = DataValuesStruct.TimeRaw;
        TimeARawHalf = temp(integerMask);
        CondRawHalf = TimeARawHalf < TimeMax & TimeARawHalf > TimeMin;
    end

    refDate = datetime(2000, 1, 1);
    dt = refDate + days(TimeFiltered);
    dt.Format = 'dd-MMM-yyyy hh:mm:ss';
    AttrNames = {nc_gen_Attributes.Name};
    idxS = strcmp(AttrNames,'Time coverage start');
    nc_gen_Attributes(idxS).Value = char(dt(1));
    idxE = strcmp(AttrNames,'Time coverage end');
    nc_gen_Attributes(idxE).Value = char(dt(end));
    currentDT = datetime('now');
    idxC = strcmp(AttrNames, 'Creation date');
    nc_gen_Attributes(idxC).Value = char(currentDT);


    %% Load the dimension catalogue
    DimVec = getDimensions(nVal, nValRaw);
    DimMask.Time        = Cond;
    DimMask.TimeRaw     = CondRaw;
    DimMask.TimeRawHalf = CondRawHalf;
    DimMask.Coef        = [];

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
%         temp = ncread(pathToFile, catVarsVec.(VarNames{i}).SourceName);
        SrcName = catVarsVec.(VarNames{i}).SourceName;
        assert( isfield(DataValuesStruct,SrcName), 'Source variable "%s" is missing.', SrcName);
        temp = DataValuesStruct.(SrcName);

        % Time-dependent variables are cropped to the selected temporal
        % interval. Static variables are kept unchanged.
        Mask = DimMask.(VarDims);
        if isempty(Mask)
            Data = temp;
        else
            Data = temp(Mask);
        end
%         if
%             Data = temp(Cond);
%         elseif strcmp(DimVec.(VarDims).Name, 'TimeRaw')
%             Data = temp(CondRaw);
%         elseif strcmp(DimVec.(VarDims).Name, 'TimeRawHalf')
%             Data = temp(CondRawHalf);
%         else
%             Data = temp;
%         end
        Var.Val2Save = Data;
        Var.Dimensions = dimids;
        Var = rmfield(Var,'Coordinates');
        Var = rmfield(Var,'SourceName');
        nc_VarSchema(i) = Var;
    end

    %% Write the NetCDF file
    ncSavVarFil( fn_netCDF, nc_VarSchema, 'Attributes', nc_gen_Attributes );

end