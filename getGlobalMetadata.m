function GlobalStruct = getGlobalMetadata()
    %% this function describes the general global metadata for atmospheric longwave data
    % 
    % 
    GlobalStruct(1).Name        = 'Title';
    GlobalStruct(1).Value       = 'Atmospheric clear-sky downward longwave radiation data';

    GlobalStruct(2).Name        = 'Summary';
    GlobalStruct(2).Value       = 'Modelisation of the atmospheric downward longwave radiation data measured at Payerne, Switzerland during clear-sky. Measurements originate from a instrument further denoted as 1, Eppley PIR pyrgeometer, and another instrument further denoted as 2, Kipp & Zonen CG4 pyrgeometer.';

    GlobalStruct(3).Name        = 'References';
    GlobalStruct(3).Value       = 'DOI:???';

    GlobalStruct(4).Name        = 'Institution';
    GlobalStruct(4).Value       = 'MeteoSwiss Payerne';

    GlobalStruct(5).Name        = 'Station_name';
    GlobalStruct(5).Value       = 'PAY (Payerne)';
    GlobalStruct(6).Name        = 'Station_scientist';
    GlobalStruct(6).Value       = 'Laurent Vuilleumier (laurent.vuilleumier@meteoswiss.ch)';
    GlobalStruct(7).Name        = 'Latitude';
    GlobalStruct(7).Value       = '46.812300';
    GlobalStruct(8).Name        = 'Longitude';
    GlobalStruct(8).Value       = '6.942200';
    GlobalStruct(9).Name        = 'Elevation';
    GlobalStruct(9).Value       = '491.0 m';
    GlobalStruct(10).Name       = 'Method';
    GlobalStruct(10).Value      = 'Monitoring station (MONS)';
    GlobalStruct(11).Name       = 'Comment';
    GlobalStruct(11).Value      = 'BSRN station no: 21; Surface type: cultivated; Topography type: hilly, rural';

    GlobalStruct(12).Name       = 'Conventions';
    GlobalStruct(12).Value      = 'CF-1.11 ACDD-1.3';
    GlobalStruct(13).Name       = 'Instruments';
    GlobalStruct(13).Value      = 'Instrument 1: Eppley PIR / Instrument 2: Kipp & Zonen CG4 pyrgeometer';
    GlobalStruct(14).Name       = 'License';
    GlobalStruct(14).Value      = 'Baseline Surface Radiation Network License 1.0 (BSRN-1.0)';

    GlobalStruct(15).Name       = 'History';
    GlobalStruct(15).Value      = 'Created from 1-minute averaged measurements and themselves averages on 30 minutes. Only clear-sky is present in this documentation.';
    
    GlobalStruct(16).Name       = 'Time coverage start';
    GlobalStruct(16).Value      = '01-01-2011 00:00:00';
    GlobalStruct(17).Name       = 'Time coverage end';
    GlobalStruct(17).Value      = '01-01-2026 00:00:00';
    GlobalStruct(18).Name       = 'Creation date';
    GlobalStruct(18).Value      = '01-01-2026 00:00:00';


    

end